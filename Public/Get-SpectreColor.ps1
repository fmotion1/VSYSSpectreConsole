using namespace Spectre.Console

function Get-SpectreColor {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory, Position=0)]
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color
    )
    try {
        # Already validated in validation attribute
        if($Color.StartsWith("#")) {
            $hexString = $Color -replace '^#', ''
            $hexBytes = [System.Convert]::FromHexString($hexString)
            return [Color]::new($hexBytes[0], $hexBytes[1], $hexBytes[2])
        }
        # Validated in attribute as a real color already
        return [Color]::$Color
    } catch {
        throw "'$Color' is not a valid Spectre color: ['$($spectreColors -join ''', ''')']"
    }
}