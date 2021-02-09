::
:: Revision: V1.3
:: 
:: Copyright (c) 2021 OSR Open Systems Resources, Inc.
::
::   Licensed under the Apache License, Version 2.0 (the "License");
::   you may not use this file except in compliance with the License.
::   You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
::   Unless required by applicable law or agreed to in writing, software
::   distributed under the License is distributed on an "AS IS" BASIS,
::   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
::   See the License for the specific language governing permissions and
::   limitations under the License.
::
:: RunCodeQL.bat -- Runs CodeQL on the current project
:: 	Can be run as a post-build step for a project from VS
:: 	or can be run from the command line... if you want to provide
:: 	all the required parameters.
:: 
:: RunCodeQL.bat <FQP_base_project_dir> <FQP_to_project_file_to_Build> <name_of_project> <target> <configuration> <query_set>
::
:: 	- <target> target defaults to "x64"
:: 	- <configuration> defaults to "Debug"
:: 	- <query_set> defaults to "windows_driver_recommended"
::
:: Examples:

::	Command Line:
::   RunCodeQL.bat "F:\_Work\OsrFlt\" "F:\_Work\OsrFlt\OsrFlt\OsrFlt.vcxproj" "OsrFlt" "x64" "Debug" "cpp-security-and-quality"
::
::	Post Build:
::	 call <your_directory>RunCodeQL.bat "$(solutionDir)" "$(MSBuildProjectFullPath)" "$(ProjectName)" "$(PlatformTarget)" "$(ConfigurationName)" "cpp-security-and-quality"
::
:: INSTALLING CodeQL (based on the WDK doc pages here:
:: https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql )
::
:: 1) Create a "home" directory for your code CodeQL installation (for example,
::    C:\CodeQL-Home)
::
:: 2) Download the appropriate version of CodeQL from GitHub 
:: (https://github.com/github/codeql-cli-binaries/releases/ ) and unzip it into
::    a subdirectory of your CodeQL "home" directory (for example C:\CodeQL-Home\codeql).
::
:: 3) Clone the query suites including driver-specific queries
:: (https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools.git ).
::    into a subdirectory of the "home" directory (for example, 
::    C:\CodeQL-Home\Windows-Driver-Developer-Supplemental-Tools)
::
:: 4) To view your results in anything like a reasonable way, you will need to
::    use a SARIF viewer.  There's an add-in for Visual Studio that works just
::    fine here: https://marketplace.visualstudio.com/items?itemName=WDGIS.MicrosoftSarifViewer
::
:: After running CodeQL, the SARIF file containing the results will be in the 
:: \databases sub-directory of your CodeQL "home" directory.  The name of the
:: file will be the name of your project.  If you're using the VS add-in we
:: mentioned above, simply drag the SARIF file and drop it into your VS
:: instance.
::
:: >>>> Set the following to your CodeQL "home" directory:
::
set CodeQLHome=C:\codeql-home
::
set SolutionDir=%~d1%~p1
set SolutionFQPath=%~2
set ProjectName=%~3
set PlatformTarget=%~4
IF "%PlatformTarget%" NEQ "" goto PLATFORM-SPECIFIED
set PlatformTarget=x64
:PLATFORM-SPECIFIED
set Configuration=%~5
IF "%Configuration%" NEQ "" goto CONFIG-SPECIFIED
set Configuration=Debug
:CONFIG-SPECIFIED
set QuerySet=%~6
IF "%QuerySet%" NEQ "" goto QUERY-SPECIFIED
set QuerySet="windows_driver_recommended"
:QUERY-SPECIFIED
set CodeQLBuildDir="%SolutionDir%CodeQL"
echo on
IF EXIST "%SolutionDir%CodeQL.dat" GOTO MUST-BE-RECURSIVE
echo ---- NOT RECURSIVE, creating marker file
echo working >> "%SolutionDir%CodeQL.dat"
echo  -------------- PostBuild2: %0 %1 %2 %3 %4 %5
echo -- attempting to delete %CodeQLHome%\databases\%ProjectName%
rmdir /s/q %CodeQLHome%\databases\%ProjectName%
echo -- Proceding with the CodeQL build step --
CALL %CodeQLHome%\codeql\codeql.cmd database create -l=cpp -s=%SolutionDir% -c "msbuild /t:rebuild /p:IntDir=%CodeQLBuildDir%\intermediate\;OutDir=%CodeQLBuildDir%\;Configuration=%Configuration%;Platform=%PlatformTarget% "%SolutionFQPath%" /p:UseSharedCompilation=false" "%CodeQLHome%\databases\%ProjectName%" -j 0
echo -- Proceding with the CodeQL analyze step --
CALL %CodeQLHome%\codeql\codeql.cmd database analyze "%CodeQLHome%\databases\%ProjectName%" %QuerySet%.qls --format=sarifv2.1.0 --output="%CodeQLHome%\databases\%ProjectName%.sarif" -j 0
del "%SolutionDir%CodeQL.dat"
::echo -- Proceding with the viewing results from %CodeQLHome%\databases\%ProjectName%.sarif --
::CALL devenv /edit %CodeQLHome%\databases\%ProjectName%.sarif
GOTO END

:MUST-BE-RECURSIVE
ECHO ---------- Recursive invocation... skipping CodeQL invocation

:END
set ERRORLEVEL=0
