using namespace Spectre.Console
function Format-SpectreTable {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console table.
    ![Example table](/table.png)

    .DESCRIPTION
    This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.

    .PARAMETER Data
    The array of objects to be formatted into a table.

    .PARAMETER Border
    The border style of the table. Default is "Double".

    .PARAMETER Color
    The color of the table border. Default is the accent color of the script.

    .PARAMETER Width
    The width of the table.

    .PARAMETER HideHeaders
    Hides the headers of the table.

    .PARAMETER Title
    The title of the table.

    .EXAMPLE
    # This example formats an array of objects into a table with a double border and the accent color of the script.
    $data = @(
        [pscustomobject]@{Name="John"; Age=25; City="New York"},
        [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
    )
    Format-SpectreTable -Data $data
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTable")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [ValidateSet([SpectreConsoleTableBorder],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [ValidateScript({ $_ -gt 0 -and $_ -le [console]::BufferWidth }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int]$Width,
        [switch]$HideHeaders,
        [String]$Title
    )
    begin {
        $table = [Table]::new()
        $table.Border = [TableBorder]::$Border
        $table.BorderStyle = [Style]::new(($Color | Get-SpectreColor))
        $headerProcessed = $false
        if ($Width) {
            $table.Width = $Width
        }
        if ($HideHeaders) {
            $table.ShowHeaders = $false
        }
        if ($Title) {
            $table.Title = [TableTitle]::new($Title, [Style]::new(($Color | Get-SpectreColor)))
        }
    }
    process {
        if(!$headerProcessed) {
            $Data[0].psobject.Properties.Name | Foreach-Object {
                $table.AddColumn($_) | Out-Null
            }
            $headerProcessed = $true
        }

        $Data | Foreach-Object {
            $row = @()
            $row = $_.psobject.Properties | ForEach-Object {
                $cell = $_.Value
                if ($null -eq $cell) {
                    [Markup]::new("")
                }
                else {
                    [Markup]::new($cell.ToString())
                }
            }

            $table = [TableExtensions]::AddRow($table, [Markup[]]$row)
        }
    }
    end {
        Write-AnsiConsole $table
    }
}
