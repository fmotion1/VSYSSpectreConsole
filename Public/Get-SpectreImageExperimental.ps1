using namespace SixLabors.ImageSharp
function Get-SpectreImageExperimental {
    <#
    .SYNOPSIS
    Displays an image in the console using block characters and ANSI escape codes.
    :::caution
    This is experimental.
    :::

    .DESCRIPTION
    This function loads an image from a file and displays it in the console using block characters and ANSI escape codes. The image is scaled to fit within the specified maximum width while maintaining its aspect ratio. If the image is an animated GIF, each frame is displayed in sequence with a configurable delay between frames.

    .PARAMETER ImagePath
    The path to the image file to display.

    .PARAMETER Width
    The width of the image in characters. The image is scaled to fit within this width while maintaining its aspect ratio.

    .PARAMETER Repeat
    If specified, the animation will repeat indefinitely.

    .PARAMETER Resampler
    The resampling algorithm to use when scaling the image. Valid values are "Bicubic" and "NearestNeighbor". The default value is "Bicubic".

    .EXAMPLE
    # Displays the image "MyImage.png" in the console with a maximum width of 80 characters.
    PS C:\> Get-SpectreImageExperimental -ImagePath "C:\Images\MyImage.png" -MaxWidth 80

    .EXAMPLE
    # Displays the animated GIF "MyAnimation.gif" in the console with a maximum width of 80 characters, repeating indefinitely.
    PS C:\> Get-SpectreImageExperimental -ImagePath "C:\Images\MyAnimation.gif" -MaxWidth 80 -Repeat
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreImageExperimental")]
    param (
        [string] $ImagePath,
        [int] $Width,
        [int] $LoopCount = 0,
        [ValidateSet("Bicubic", "NearestNeighbor")]
        [string] $Resampler = "Bicubic"
    )

    $cursorPosition = $Host.UI.RawUI.CursorPosition
    Write-Host -NoNewline "Loading image... "

    $imagePathResolved = Resolve-Path $ImagePath
    if (-not (Test-Path $imagePathResolved)) {
        throw "The specified image path '$resolvedImagePath' does not exist."
    }

    $bgColor = [System.Drawing.Color]::FromName([Console]::BackgroundColor)
    
    $image = [Image]::Load($ImagePath)

    if (!$Width) {
        $Width = $image.Width
    }

    $maxWidth = $Host.UI.RawUI.WindowSize.Width
    $maxHeight = ($Host.UI.RawUI.WindowSize.Height - 2) * 2
    $scaledHeight = [int]($image.Height * ($Width / $image.Width))
    if ($scaledHeight -gt $maxHeight) {
        $scaledHeight = $maxHeight
    }

    $scaledWidth = [int]($image.Width * ($scaledHeight / $image.Height))
    if ($scaledWidth -gt $maxWidth) {
        $scaledWidth = $maxWidth
        $scaledHeight = [int]($image.Height * ($scaledWidth / $image.Width))
    }

    [Processing.ProcessingExtensions]::Mutate($image, {
            param($Context)
            [Processing.ResizeExtensions]::Resize(
                $Context,
                $scaledWidth,
                $scaledHeight,
                [Processing.KnownResamplers]::$Resampler
            )
        })

    $frames = @()
    $buffer = [System.Text.StringBuilder]::new($scaledWidth * $scaledHeight * 2)

    foreach ($frame in $image.Frames) {
        $frameDelayMilliseconds = 1000
        try {
            $frameMetadata = [MetadataExtensions]::GetGifMetadata($frame.Metadata)
            if ($frameMetadata.FrameDelay) {
                # The delay is supposed to be in milliseconds and imagesharp seems to
                # be a bit out when it decodes it
                $frameDelayMilliseconds = $frameMetadata.FrameDelay * 10
            }
        } catch {
            # Don't care
        }
        $buffer.Clear() | Out-Null
        for ($y = 0; $y -lt $scaledHeight; $y += 2) {
            for ($x = 0; $x -lt $MaxWidth; $x++) {
                $curPixel = $frame[$x, $y]
                if ($null -ne $curPixel.A) {
                    # Quick-hack blending the foreground with the terminal background
                    # color. This could be done in imagesharp
                    $fgMultiplier = $curPixel.A / 255
                    $bgMultiplier = 100 - $fgMultiplier
                    $curPixelRgb = @{
                        R = [math]::Min(255, ($curPixel.R * $fgMultiplier + $bgColor.R * $bgMultiplier))
                        G = [math]::Min(255, ($curPixel.G * $fgMultiplier + $bgColor.G * $bgMultiplier))
                        B = [math]::Min(255, ($curPixel.B * $fgMultiplier + $bgColor.B * $bgMultiplier))
                    }
                } else {
                    $curPixelRgb = @{
                        R = $curPixel.R
                        G = $curPixel.G
                        B = $curPixel.B
                    }
                }

                # Parse the image 2 vertical pixels at a time and use the lower half
                # block character with varying foreground and background colors to
                # make it appear as two pixels within one character space
                if ($image.Height -ge ($y + 1)) {
                    $pixelBelow = $frame[$x, ($y + 1)]

                    if ($null -ne $pixelBelow.A) {
                        # Quick-hack blending the foreground with the terminal
                        # background color. This could be done in imagesharp
                        $fgMultiplier = $pixelBelow.A / 255
                        $bgMultiplier = 100 - $fgMultiplier
                        $pixelBelowRgb = @{
                            R = [math]::Min(255, ($pixelBelow.R * $fgMultiplier + $bgColor.R * $bgMultiplier))
                            G = [math]::Min(255, ($pixelBelow.G * $fgMultiplier + $bgColor.G * $bgMultiplier))
                            B = [math]::Min(255, ($pixelBelow.B * $fgMultiplier + $bgColor.B * $bgMultiplier))
                        }
                    } else {
                        $pixelBelowRgb = @{
                            R = $pixelBelow.R
                            G = $pixelBelow.G
                            B = $pixelBelow.B
                        }
                    }

                    $buffer.Append(("$([Char]27)[38;2;{0};{1};{2}m" -f
                            $pixelBelowRgb.R,
                            $pixelBelowRgb.G,
                            $pixelBelowRgb.B
                        )) | Out-Null
                }

                $buffer.Append(("$([Char]27)[48;2;{0};{1};{2}m$([Char]0x2584)$([Char]27)[0m" -f
                        $curPixelRgb.R,
                        $curPixelRgb.G,
                        $curPixelRgb.B
                    )) | Out-Null
            }
            $buffer.AppendLine() | Out-Null
        }

        $frames += @{
            FrameDelayMS = $frameDelayMilliseconds
            Frame                  = $buffer.ToString().Trim()
        }
    }

    $Host.UI.RawUI.CursorPosition = $cursorPosition

    # TODO: Fix this. It's haaaaacked together and not properly done
    $cursorPosition = $Host.UI.RawUI.CursorPosition
    $remainingRows = $Host.UI.RawUI.WindowSize.Height - $cursorPosition.Y - 1
    $rowsToClear = [int]($scaledHeight / 2) - 1
    -1..$rowsToClear | ForEach-Object {
        Write-Host ""
    }
    $newYPosition = 0
    if ($rowsToClear -ge $remainingRows) {
        $newYPosition = $cursorPosition.Y + $remainingRows - $rowsToClear - 2
    } else {
        $newYPosition = $cursorPosition.Y
    }
    [Console]::SetCursorPosition($cursorPosition.X, $newYPosition)

    $topLeft = $Host.UI.RawUI.CursorPosition
    $loopIterations = 0
    [Console]::SetCursorPosition($topLeft.X, $topLeft.Y)
    [Console]::CursorVisible = $false
    do {
        foreach ($frame in $frames) {
            [Console]::SetCursorPosition($topLeft.X, $topLeft.Y)
            Write-Host $frame.Frame
            Start-Sleep -Milliseconds $frame.FrameDelayMS
        }
        $loopIterations++
    } while ($loopIterations -lt $LoopCount)
    [Console]::CursorVisible = $true
}