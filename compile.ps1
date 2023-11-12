$compress = @{
    Path             = ".\.love-file", ".\*.lua", ".\assets", ".\lib"
    CompressionLevel = "Fastest"
    DestinationPath  = ".\PortalPush.zip"
}

$filesToDelete = @(
    "$PWD\PortalPush.exe", "$PWD\PortalPush.love", "$PWD\PortalPush.exe",
    "$PWD\PortalPush.zip", "$PWD\build\PortalPush.exe", "$PWD\build\PortalPush.love",
    "$PWD\build\love.exe"
)

foreach ($file in $filesToDelete) {
    Write-Debug -Message "$file"
    if ([System.IO.File]::Exists($file)) {
        Remove-Item -Path $file
    }
}

if (![System.IO.Directory]::Exists("$PWD\build")) {
    New-Item -Path "$PWD" -Name "build" -ItemType Directory
}

Compress-Archive @compress

Rename-Item -Path "$PWD\PortalPush.zip" -NewName "PortalPush.love"
Move-Item -Path "$PWD\PortalPush.love" -Destination "$PWD\build"

Set-Location "$PWD/build"
New-Item -Path "$PWD" -Name "PortalPush.exe"

$loveFiles = @(
    "love.exe", "SDL2.dll", "OpenAL32.dll", "license.txt",
    "love.dll", "lua51.dll", "mpg123.dll", "msvcp120.dll", "msvcr120.dll"
)

foreach ($file in $loveFiles) {
    Copy-Item -Path "C:\Program Files\LOVE\$file" -Destination "$PWD"
}
cmd /c copy /b love.exe+PortalPush.love PortalPush.exe
Set-Location ".."
