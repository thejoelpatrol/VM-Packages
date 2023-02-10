$ErrorActionPreference = 'Stop'
Import-Module vm.common -Force -DisableNameChecking

try {
    $toolSrcDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    
    $packageArgs = @{
        packageName   = ${Env:ChocolateyPackageName}
        unzipLocation = $toolSrcDir
        url           = 'https://github.com/therealdreg/DbgChild/releases/download/beta10/DbgChild.Beta.10.zip'
        checksum      = 'f17f588795d8f5f94d71335a8acfa58946bb03a94a5637be7f3e804c652ea2b4'
        checksumType  = 'sha256'
    }
    Install-ChocolateyZipPackage @packageArgs
    $toolSrcDir = Join-Path $toolSrcDir 'DbgChild Beta 10'
    VM-Assert-Path $toolSrcDir

    $archs = @("x32", "x64")
    foreach ($arch in $archs) {
        $archDstDir = Join-Path ${Env:RAW_TOOLS_DIR} "x64dbg\release\${arch}" -Resolve
        $pluginDstDir = Join-Path $archDstDir 'plugins'
        if (-Not (Test-Path $pluginDstDir -PathType Container)) {
            New-Item -ItemType directory $pluginDstDir -Force -ea 0 | Out-Null
        }
        VM-Assert-Path $pluginDstDir

        # Move 32/64-bit plugin DLL itself into the arch directory
        $pluginSrcPath = Join-Path $toolSrcDir "release\${arch}\plugins" -Resolve
        Get-ChildItem -Path $pluginSrcPath -File | Move-Item -Destination $pluginDstDir -Force -vb
        
        # Note that we don't simply move all children including directories, because we don't want to overwrite plugins

        # Move all the other arch-specific files
        $archSrcPath = Join-Path $toolSrcDir "release\${arch}" -Resolve
        Get-ChildItem -Path $archSrcPath -File | Move-Item -Destination $archDstDir -Force -vb
        if (-Not(Test-Path "${archDstDir}\CPIDS" -PathType Container)) {
            Move-Item -Path "${archSrcPath}\CPIDS" -Destination $archDstDir -vb
        }        
    }

    # Move the NewProcessWatcher and text files into the main x64dbg directory
    $releasePath = Join-Path $toolSrcDir 'release'
    $x64dbgPath = Join-Path ${Env:RAW_TOOLS_DIR} 'x64dbg\release'
    Get-ChildItem -Path $releasePath -File | Move-Item -Destination $x64dbgPath -Force -vb
    if (-Not(Test-Path "${x64dbgPath}\dbgchildlogs" -PathType Container)) {
        Move-Item -Path "${releasePath}\dbgchildlogs" -Destination $x64dbgPath -vb
    }

    Remove-Item -Path $toolSrcDir -Recurse -Force -ea 0
} catch {
    VM-Write-Log-Exception $_
}
