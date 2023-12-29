# Import Classes
try {
    Get-ChildItem -Path "$PSScriptRoot\class\*.ps1" -Recurse | ForEach-Object {
        Write-Host "Loaded"
        . $_.FullName
    }
}
catch {
    throw "There was a problem importing classes." 
}

# Import Themes
try {
    . "$PSScriptRoot\data\SyntaxHighlightingThemes.ps1"
}
catch {
    throw "There was a problem importing the syntax highlighting themes."       
}

# Import Default Colors
try {
    . "$PSScriptRoot\data\DefaultColors.ps1"
}
catch {
    throw "There was a problem importing default colors."       
}


# Import Private and Public Functions
Foreach ($import in @('private', 'public')) {
    Try {
        Get-ChildItem -Path "$PSScriptRoot\$import\*.ps1" -Recurse | ForEach-Object {
            . $_.FullName
        }
    } Catch {
        $eMessage = "There was a problem importing $import."
        $eRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList (
            (New-Object -TypeName Exception -ArgumentList $eMessage),
            'ModuleDotsourceError',
            [System.Management.Automation.ErrorCategory]::SyntaxError,
            $import
        )
        Write-Error $eMessage
        throw $eRecord
    }
}