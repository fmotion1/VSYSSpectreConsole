@{
    RootModule = "VSYSSpectreConsole.psm1"
    ModuleVersion = '1.3.0'
    GUID = '29204cf3-23cf-5ba6-a227-c61e5a7d4430'
    Author = 'Shaun Lawrie, Forked by Fmotion1'
    CompanyName = 'Futuremotion'

    Description = 'A convenient PowerShell wrapper for Spectre.Console'
    PowerShellVersion = '7.0'

    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FileList = @()

    # Leave commented out to import into any host.
    # PowerShellHostName = ''

    RequiredModules =    ''

    RequiredAssemblies = "$PSScriptRoot\Lib\Spectre.Console.dll",
                         "$PSScriptRoot\Lib\Spectre.Console.ImageSharp.dll",
                         "$PSScriptRoot\Lib\SixLabors.ImageSharp.dll"

    FunctionsToExport =  'Add-SpectreJob',
                         'Format-SpectreBarChart', 
                         'Format-SpectreBreakdownChart',
                         'Format-SpectrePanel', 
                         'Format-SpectreTable',
                         'Format-SpectreTree',
                         'Get-SpectreColor',
                         'Get-SpectreDemoColors',
                         'Get-SpectreDemoEmoji',
                         'Get-SpectreEscapedText',
                         'Get-SpectreImage',
                         'Get-SpectreImageExperimental', 
                         'Invoke-SpectreCommandWithProgress',
                         'Invoke-SpectreCommandWithStatus',
                         'Invoke-SpectreScriptBlockQuietly', 
                         'New-SpectreChartItem',
                         'Read-SpectreConfirm',
                         'Read-SpectreMultiSelection',
                         'Read-SpectreMultiSelectionGrouped',
                         'Read-SpectrePause', 
                         'Read-SpectreSelection',
                         'Read-SpectreText',
                         'Set-SpectreColors', 
                         'Start-SpectreDemo',
                         'Wait-SpectreJobs',
                         'Write-AnsiConsole',
                         'Write-SpectreFigletText', 
                         'Write-SpectreHost',
                         'Write-SpectreRule'    

    PrivateData = @{
        PSData = @{
            Tags = @('SpectreConsole', 'Spectre', 'Console', 'Windows')
            LicenseUri = 'https://github.com/fmotion1/VSYSSpectreConsole/blob/main/LICENSE.md'
            ProjectUri = 'https://github.com/fmotion1/VSYSSpectreConsole'
            IconUri = ''
            ReleaseNotes = '1.3.0: (12/22/2023) - Fork by Fmotion1'
        }
    }
}

