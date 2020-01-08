# The Unlicense
# January 2020
# b3b0
# https://github.com/b3b0/checkPatch

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$mainfolder = "C:\Users\$env:UserName\ThirdPartyCheck"
$javaLatest = "C:\Users\$env:UserName\ThirdPartyCheck\javaLatestVersion.txt"
$javaRaw = "C:\Users\$env:UserName\ThirdPartyCheck\javaRaw.txt"
$flashLatest = "C:\Users\$env:UserName\ThirdPartyCheck\flashLatestVersion.txt"
$flashRaw = "C:\Users\$env:UserName\ThirdPartyCheck\flashRaw.txt"
$itunesLatest = "C:\Users\$env:UserName\ThirdPartyCheck\itunesLatestVersion.txt"
$itunesRaw = "C:\Users\$env:UserName\ThirdPartyCheck\itunesRaw.txt"

$javaURL = "https://www.java.com/en/download/"
$flashURL = "https://get.adobe.com/flashplayer/"
$itunesURL = "https://en.m.wikipedia.org/wiki/History_of_iTunes"

if( -not (Test-Path $mainfolder -PathType Container))
{
    New-Item -ItemType "directory" -Path $mainfolder
}

function emailer($application, $newversion, $oldversion,$url)
{
    $EmailFrom = "ThirdPartyUpdateTracker@yourdomain.com"
    $EmailTo = "you@yourdomain.com"
    $Subject ="$application has received an update!" 
    $Body = "Old version: $oldversion `nNew Version: $newversion`nSource: $url`n"
    $SMTPServer = "yoursmtp.yourdomain.com"
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
    #$SMTPClient.EnableSsl = $false or $true
    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}

function javaFinder()
{
    $javaLatestVer = Get-Content $javaLatest
    $javaLatestVer = $javaLatestVer -replace "`n",", " -replace "`r",", "
    if ( -not (Test-Path $javaLatest -PathType Leaf))
    {
        New-Item -ItemType "file" -Path $javaLatest
    }
    Invoke-WebRequest $javaURL -OutFile $javaRaw 
    $javaTodayCheck = Get-Content $javaRaw | select-string "Version 8"
    if ($javaTodayCheck -notin (Get-Content $javaLatest))
    {
        #Write-Host "Updated!"
        emailer "Java" $javaTodayCheck $javaLatestVer $javaURL
        Write-Output $javaTodayCheck > $javaLatest
    }
}

function flashFinder()
{
    $flashLatestVer = Get-Content $flashLatest
    $flashLatestVer = $flashLatestVer -replace "`n",", " -replace "`r",", "
    if ( -not (Test-Path $flashLatest -PathType Leaf))
    {
        New-Item -ItemType "file" -Path $flashLatest
    }
    Invoke-WebRequest $flashURL -OutFile $flashRaw 
    $flashTodayCheck = Get-Content $flashRaw | Select-String "<strong>Version"
    $Regex = [Regex]::new("(?<=Version)(.*)(?=</strong)")
    $matchmaker = $Regex.Match($flashTodayCheck)
    $flashTodayCheck = $matchmaker.Value
    if ($flashTodayCheck -notin (Get-Content $flashLatest))
    {
        #Write-Host "Updated!"
        emailer "Flash" $flashTodayCheck $flashLatestVer $flashURL
        Write-Output $flashTodayCheck > $flashLatest
    }
}

function itunesFinder()
{
    $itunesNew = "12.10.3.1"
    if ( -not (Test-Path $itunesLatest -PathType Leaf))
    {
        New-Item -ItemType "file" -Path $itunesLatest
    }
    Invoke-WebRequest $itunesURL -OutFile $itunesRaw
    Get-Content $itunesRaw | Select-String $itunesNew -Context 0,10 > $mainfolder\itunescontext.txt
    if (-not((Get-Content $mainfolder\itunescontext.txt | Select-String "See also")))
    {
        #Write-Host "Updated!"
        emailer "iTunes" "UPDATE YOUR SCRIPT!" $itunesNew $itunesURL
    } 
}

javaFinder
flashFinder
itunesFinder

$eventime = Get-Date
Write-Output "Completed at $eventime" >> "$mainfolder/TPUC.log"
