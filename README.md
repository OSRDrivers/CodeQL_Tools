# CodeQL_Tools

This repo contains some miscellaneous things we've been using to play with CodeQL, Microsoft's new static code analyzer.  

## RunCodeQL.bat

Runs CodeQL on the current project. Designed to be used for analyzing drivers and with the WDK installed.

Can be run as a post-build step for a project from VS or can be run from **the Visual Studio Command Prompt**.

Parameters:

```
     RunCodeQL.bat <FQP_base_project_dir> <FQP_to_project_file_to_Build> <name_of_project> <target> <configuration> <query_set>
```

Defaults:

- \<target> defaults to "x64"
- \<configuration> defaults to "Debug"
- \<query_set> defaults to "windows_driver_recommended"

### Usage Examples:

Command Line:
    
```
     RunCodeQL.bat "F:\_Work\OsrFlt\" "F:\_Work\OsrFlt\OsrFlt\OsrFlt.vcxproj" "OsrFlt" "x64" "Debug" "cpp-security-and-quality"
```

Post Build:
     
```
call <your_directory>RunCodeQL.bat "$(solutionDir)" "$(MSBuildProjectFullPath)" "$(ProjectName)" "$(PlatformTarget)" "$(ConfigurationName)" "cpp-security-and-quality"
```

### INSTALLING CodeQL for use with this command procedure 
These instructions are based on the [WDK doc pages](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql), which have some good examples of installation and use of CodeQL for drivers.

1) Create a "home" directory for your code CodeQL installation (for example,
C:\CodeQL-Home)

2) Download the appropriate version of [CodeQL from GitHub](https://github.com/github/codeql-cli-binaries/releases/) and unzip it into
a subdirectory of your CodeQL "home" directory (for example C:\CodeQL-Home\codeql).

3) Clone [the query suites](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools.git) including driver-specific queries into a subdirectory of the "home" directory (for example,  'C:\CodeQL-Home\Windows-Driver-Developer-Supplemental-Tools')

4) To view your results in anything like a reasonable way, you will need to
use a SARIF viewer.  There's an add-in for Visual Studio that works just
fine [here](https://marketplace.visualstudio.com/items?itemName=WDGIS.MicrosoftSarifViewer)

After running CodeQL, the SARIF file containing the results will be in the 
databases sub-directory of your CodeQL "home" directory (for example,
C:\codeql-home\databases\).  The name of the file with your results will be the name of your project.
If you're using the VS or VS Code add-in to interpret SARIF, simply drag the SARIF file and drop it
into your VS or VS Code instance.

**If your CodeQL "home" directory is something other than "C:\codeql-home" be sure to
set that in appropriate variable in the batch file**

