$compress = @{
    Path             = ".\.love-file", ".\*.lua", ".\assets", ".\lib"
    CompressionLevel = "Fastest"
    DestinationPath  = ".\PortalPush.zip"
}

if ([System.IO.File]::Exists("$PWD\PortalPush.zip")) {
    Remove-Item -Path "$PWD\PortalPush.zip"
}
Compress-Archive @compress
if ([System.IO.File]::Exists("$PWD\PortalPush.love")) {
    Remove-Item -Path "$PWD\PortalPush.love"
}
Rename-Item -Path "$PWD\PortalPush.zip" -NewName "PortalPush.love"
