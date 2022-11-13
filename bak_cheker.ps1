[psobject[]]$result = $null;
$html = $null
$paths = "E:\folder", "F:\folder"
$servername = $env:computername + "@domain.com"
$Logfile = "C:\Logs\SQL_$env:computername.log"
function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}
Foreach ($path in $paths){
    WriteLog "Запуск скрипта по директории $path"
    $dirs = Get-ChildItem -Path $path -Recurse -Include *.bak
    foreach ($dir in $dirs){
        if (-not $dir.PSIsContainer -and $dir.Length -le 5000){
        $Result += [pscustomobject]@{Path = $dir.FullName; FileSize = "{0:N2}" -f($dir.Length/1kb) + "KB"}
        }
    }
}
if ($result -ne $null) {
        Writelog ($result | Format-Table | Out-String) #([system.String]::Join("`n", $result.Path + $result.FileSize))
		$mailobject = $result | Select @{Name="Путь"; Expression={$_.path}}, @{Name="Размер"; Expression={$_.FileSize}}
		$table = "<style>"
		$table = $table + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
		$table = $table + "TH{font-family: Arial;border-width: 1px;padding: 6px;border-style: solid;border-color: black;background-color:palegreen}"
		$table = $table + "TD{font-family: Arial;border-width: 1px;padding: 6px;border-style: solid;border-color: black;background-color:white}"
		$table = $table + "</style>"
        $html = $mailobject | ConvertTo-Html -head $table
        $from = $servername
        $to = 'mail@domain.com'
        $Subj = "Размер бекапов SQL сервера $env:computername"
        $Body = $html
        $SMTPServer = 'smtp.domain.com'
        $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
        $message = New-Object System.Net.Mail.MailMessage($from, $to, $subj, $body)
        $message.cc.add('sysadmin@domain.com')
        $message.isBodyHtml = $true
        $SMTPClient.Send($message)
}
 else {
        Writelog "Проблем с размерами бекапов не обнаружено"    
    }
Writelog "Конец"
Writelog "_____________________________________________________"
