
$routerAddress = "localhost"
$port = "55555"
$tcp = New-Object System.Net.Sockets.TcpClient($routerAddress,$Port)
$tcpstream = $tcp.GetStream()
$reader = New-Object System.IO.StreamReader($tcpStream)
$writer = New-Object System.IO.StreamWriter($tcpStream)
$writer.AutoFlush = $true

while ($tcp.Connected)
{       
write-host ([char]$reader.Read()) -NoNewline
while(($reader.Peek() -ne -1) -or ($tcp.Available)){        
    write-host ([char]$reader.Read()) -NoNewline
}
if ($tcp.Connected)
{
    Write-Host -NoNewline "_"
    $command = Read-Host

    if ($command -eq "escape")
    {
        break
    }
    $writer.WriteLine($command) | Out-Null
}     
}
$reader.Close()
$writer.Close()
$tcp.Close()
