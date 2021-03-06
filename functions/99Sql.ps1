$ErrorActionPreference='Stop'

cd $PSScriptRoot

function Get-ConnectionString{
    param(
        [Parameter(Mandatory)]
        [string]$DataSource,
        [PsDefaultValue(Help='master')]
        [string]$InitialCatalog='master',
        [PsDefaultValue(Help='120 seconds')]
        [int]$ConnectionTimeout=120    
    )
    return "Data Source={0};Integrated Security=true;Initial Catalog={1};Connection Timeout={2}" -f $DataSource, $InitialCatalog, $ConnectionTimeout
<#
.DESCRIPTION 
Gets MSSQL connection string.

.SYNOPSIS
Gets MSSQL connection string.

.EXAMPLE
PS> Get-ConnectionString -DataSource 'localhost\SQLEXPRESS'

.EXAMPLE 
PS> Get-ConnectionString -DataSource 'localhost\SQLEXPRESS' -InitialCatalog 'master'

.EXAMPLE
PS> Get-ConnectionString -DataSource 'localhost\SQLEXPRESS' -InitialCatalog 'master' -ConnectionTimeout 120

.INPUTS
System.Int32
System.String

.OUTPUTS
System.String

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function SqlBulkCopy-Table{
    param(
        [Parameter(Mandatory)]
        [string]$SourceDataSource,
        [Parameter(Mandatory)]
        [string]$DestinationDataSource,
        [Parameter(Mandatory)]
        [string]$SourceTable,
        [string]$DestinationTable,
        [PsDefaultValue(Help='1000 rows')]
        [int]$BulkCopyBatchSize=1000,
        [PsDefaultValue(Help='120 seconds')]
        [int]$BulkCopyTimeoutSeconds=120,
        [PsDefaultValue(Help=$true)]
        [bool]$BulkCopyStreaming=$true,
        [PsDefaultValue(Help='120 seconds')]
        [int]$ConnectionTimeout=120  
    )

    $SourceTablePieces=$SourceTable.Split('.')
    if($SourceTablePieces.count -ne 3){
        write-warning 'Source table does not contains all required sections: <table_catalog>.<table_schema>.<table_name>'
        throw
    }
    [string]$SourceTableCatalog=$SourceTablePieces[0].Replace('[','').Replace(']','')

    if(!$DestinationTable){
        $DestinationTable=$SourceTable
        [string]$DestTableCatalog=$SourceTableCatalog
        [string]$DestTableName=$SourceTableName
    }else{
        $DestTablePieces=$DestinationTable.Split('.')
        if($DestTablePieces.count -ne 3){
            write-warning 'Destination table does not contains all required sections: <table_catalog>.<table_schema>.<table_name>'
            throw
        }
        [string]$DestTableCatalog=$DestTablePieces[0].Replace('[','').Replace(']','')
        [string]$DestTableName=$DestTablePieces[2].Replace('[','').Replace(']','')
    }

    [string]$SourceConnStr = Get-ConnectionString -DataSource $SourceDataSource -InitialCatalog $SourceTableCatalog -ConnectionTimeout $ConnectionTimeout
    [string]$DestConnStr = Get-ConnectionString -DataSource $DestinationDataSource -InitialCatalog $DestTableCatalog -ConnectionTimeout $ConnectionTimeout

    Write-Host "Copying... [SOURCE] => [DESTINATION] "
    Write-Host "$SourceDataSource ($SourceTable) => $DestinationDataSource($DestinationTable)"
   
    try{
        $SourceConn = New-Object System.Data.SqlClient.SqlConnection
        $SourceConn.ConnectionString = $SourceConnStr
        $SourceConn.Open()

        # Get source table columns properties in case destination table does not exists
        $GetSourceTableColumnsStructure = $SourceConn.CreateCommand()
        $GetSourceTableColumnsStructure.CommandText="SELECT CONCAT('[',name, '] ',system_type_name, CASE WHEN is_identity_column=1 THEN ' IDENTITY(1,1) ' ELSE ' ' END, CASE WHEN is_nullable=0 THEN 'NOT NULL' ELSE 'NULL' END,',') as Columns_Properties FROM sys.dm_exec_describe_first_result_set( N'SELECT * FROM $SourceTable', NULL, 0 );"
        $Adp=New-Object System.Data.SqlClient.SqlDataAdapter $GetSourceTableColumnsStructure
        $SourceTableColumnsStructure=New-Object System.Data.DataSet
        $Adp.Fill($SourceTableColumnsStructure) | Out-Null
        [string]$ColumnsProperties=$SourceTableColumnsStructure.Tables.Columns_Properties
        $ColumnsProperties=$ColumnsProperties.Substring(0, $ColumnsProperties.Length -1)
       
        # Get source table content         
        $GetSourceData = $SourceConn.CreateCommand()
        $GetSourceData.CommandText = "SELECT * FROM $SourceTable"
        $SourceData = $GetSourceData.ExecuteReader()

        $DestConn = New-Object System.Data.SqlClient.SqlConnection
        $DestConn.ConnectionString = $DestConnStr
        $DestConn.Open()

        # prepare destination database
        # Create table if not exists
        # Truncate table if contains any data
        $CmdCheckDestTable=$DestConn.CreateCommand()
        $Query=(@"
        IF isnull((SELECT OBJECT_ID('{0}')),0)=0
            CREATE TABLE {1}(
		        {2}
	        ) ON [PRIMARY];
    
        IF isnull((SELECT OBJECT_ID('{0}')),0)!=0
            TRUNCATE TABLE {1};
        
"@) -f $DestTableName, $DestinationTable, $ColumnsProperties
        $CmdCheckDestTable.CommandText=$($Query)
        $CmdCheckDestTable.ExecuteScalar() | Out-Null

        # Get destination table rows number
        $CmdRowCount = $DestConn.CreateCommand()
        $CmdRowCount.CommandText = "SELECT count(*) FROM $DestinationTable"
        $CountStart = $CmdRowCount.ExecuteScalar()
        $CmdRowCount.Dispose()
        Write-Host "Destination table row count = $CountStart"

        # Copy content from source to destination
        $BulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($DestConn)
        $BulkCopy.DestinationTableName=$DestinationTable
        $BulkCopy.BatchSize=$BulkCopyBatchSize
        $BulkCopy.BulkCopyTimeout=$BulkCopyTimeoutSeconds
        $BulkCopy.EnableStreaming=$BulkCopyStreaming
        $BulkCopy.WriteToServer($SourceData)
    
        # Get copy counters
        $CountEnd = $CmdRowCount.ExecuteScalar()
        $CmdRowCount.Dispose()
        Write-Host "Ending row count = $CountEnd"
        Write-Host ("{0} rows were added." -f ($CountEnd-$CountStart))
    }catch{
        write-warning "Cannot copy table $SourceTable"
        throw $_
    }finally{
        $SourceData.Close()
        $SourceConn.Close()
        $DestConn.Close()
    }
    
<#
.DESCRIPTION 
Copy table between Source and Destination with SQLBulkCopy Class. If destination table does not exists then it will be automatically created based on information
gathered from source table columns properties. 

If destination table exists it will be truncated before importing source data to prevent doubled data.

.SYNOPSIS
Copy table from Source to Destination.

.EXAMPLE
PS> SqlBulkCopy-Table -SourceDataSource 'server1\SQLEXPRESS' -DestinationDataSource 'server2\SQLEXPRESS' -SourceTable 'catalog.dbo.Table' -DestinationTable 'catalog.dbo.Table'
Copy table to identical structure at other db server. The same effect can be done without -DestinationTable parameter:

PS> SqlBulkCopy-Table -SourceDataSource 'server1\SQLEXPRESS' -DestinationDataSource 'server2\SQLEXPRESS' -SourceTable 'catalog.dbo.Table'

.EXAMPLE
PS> SqlBulkCopy-Table -SourceDataSource 'server1\SQLEXPRESS' -DestinationDataSource 'server2\SQLEXPRESS' -SourceTable 'catalog.dbo.Table' -DestinationTable 'catalog1.dbo.Table2'
Copy table to different server, catalog and table.

.EXAMPLE
PS> SqlBulkCopy-Table -SourceDataSource 'server1\SQLEXPRESS' -DestinationDataSource 'server2\SQLEXPRESS' -SourceTable 'catalog.dbo.Table' -BulkCopyBatchSize 10000 -BulkCopyTimeoutSeconds 120 -BulkCopyStreaming $true

.INPUTS
System.Int64
System.Int32
System.String
System.Boolean

.LINK
https://ziolkowsky.wordpress.com/2022/05/08/powershell-copy-mssql-table-between-different-db-instances/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}