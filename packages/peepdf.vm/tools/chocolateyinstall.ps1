$ErrorActionPreference = 'Stop'
Import-Module vm.common -Force -DisableNameChecking

try {
    $toolSrcDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    $toolSrcDir = Join-Path $toolSrcDir 'peepdf'

    $packageArgs = @{
        packageName   = ${Env:ChocolateyPackageName}
        unzipLocation = $toolSrcDir
        url           = 'https://github.com/hatching/peepdf/archive/f6428ac1acc922b7e5fe69a756e2306a059919c7.zip'
        checksum      = '824a7be72f763afa4fa0bc263778eded8388d3b2608185c3bb932faef3f3b29d'
        checksumType  = 'sha256'
    }
    Install-ChocolateyZipPackage @packageArgs
    VM-Assert-Path $toolSrcDir

    Set-Location "${toolSrcDir}\peepdf-f6428ac1acc922b7e5fe69a756e2306a059919c7"
    echo 33333333333333333333333333333333333333
    pwd
    ls
    echo 33333333333333333333333333333333333333
    # python -m pip install .
    python setup.py install

    Remove-Item -Path $toolSrcDir -Recurse -Force -ea 0
} catch {
    VM-Write-Log-Exception $_
}