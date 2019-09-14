# Add all things you want to run before importing the main code

# Load libs
. Import-ModuleFIle -Path "$($script:ModuleRoot)\internal\scripts\loadLibs.ps1"

# Load the strings used in messages
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\strings.ps1"