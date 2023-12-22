using namespace Spectre.Console

function Write-AnsiConsole {
    param(
        [Parameter(Mandatory, Position=0)]
        [Rendering.Renderable] $RenderableObject
    )
    [AnsiConsole]::Write($RenderableObject)
}