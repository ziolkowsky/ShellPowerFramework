# Configuration
## root\Config.txt

This section is used to create .NOTIFY sections at Comment-Based HELP sections.
You can set any customized parameter you want to set at scripts descriptions.
Syntax: author.<string>=<string>
author.name=Jon Snow
author.website=forthenorth.com
author.github=github.com/youknownothingjonsnow

Framework uses by default root directory name as:
- project name
- mounting point
- ...

To change it uncomment below line.
#project.name=<string>






# Useful functions and shortcuts 
of (Open-File) - opens last created file or file passed as parameter (PS> of <file_name>)
rf (Remove-File) - removes last created file or file passed as parameter (PS> rf <file_name>)

swd (Set-WorkingDirectory) - sets working directory to last mounted path, path passed as parameter or framework root directory if any previous not founded.


