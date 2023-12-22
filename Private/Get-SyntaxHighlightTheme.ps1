function Get-SyntaxHighlightTheme {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [ValidateSet('Github','Matrix')]
        [String]
        $Theme
    )

    $SelectedTheme = $Script:SyntaxHighlightingThemes[$Theme]
    $SelectedTheme | ConvertTo-Json | ConvertFrom-Json
}