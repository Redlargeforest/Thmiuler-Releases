# Reassemble the official installer data without changing its bytes.
# Run in the folder containing all four binary download assets.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$releaseManifest = @'
{
  "originals": {
    "Thmiuler.exe": {
      "size": 11444160,
      "sha256": "65a0fc95709e526b5e20348293fd1f50bcc6fc1cbf4147feb1db91e5a4b0933a"
    },
    "Thmiuler-1.bin": {
      "size": 3488555776,
      "sha256": "f235092eac13246969a09f7c839d604fbee971f6d7e3215e996842eaa12a7372"
    },
    "Thmiuler-2.bin": {
      "size": 1192823032,
      "sha256": "af10d4a63603ee573f92faaa88f87681c9dd00eaf3a11868cd3afb7a316fc149"
    }
  },
  "downloads": {
    "Thmiuler-1.bin.part01": {
      "size": 1800000000,
      "sha256": "f1729a3bd0c3645353047bc037073d42e9ee87bc6a7c5deb35b61b12f27f9c8b"
    },
    "Thmiuler-1.bin.part02": {
      "size": 1688555776,
      "sha256": "eece69b1de5e97fad9dfb603a15699eaa01225f37409fb3f654105843ff11c52"
    },
    "Thmiuler.exe": {
      "size": 11444160,
      "sha256": "65a0fc95709e526b5e20348293fd1f50bcc6fc1cbf4147feb1db91e5a4b0933a"
    },
    "Thmiuler-2.bin": {
      "size": 1192823032,
      "sha256": "af10d4a63603ee573f92faaa88f87681c9dd00eaf3a11868cd3afb7a316fc149"
    }
  }
}
'@ | ConvertFrom-Json

function Get-ReleaseSha256([string]$FilePath) {
    $hashStream = [System.IO.File]::OpenRead($FilePath)
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($hashAlgorithm.ComputeHash($hashStream))).Replace('-', '').ToLowerInvariant()
    } finally { $hashAlgorithm.Dispose(); $hashStream.Dispose() }
}

function Assert-ReleaseFile([string]$Name, $Spec) {
    $filePath = Join-Path $PSScriptRoot $Name
    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        throw "Missing file: $Name. Download every binary asset from this release."
    }
    if ((Get-Item -LiteralPath $filePath).Length -ne [long]$Spec.size) {
        throw "Wrong size: $Name. Download the file again."
    }
    if ((Get-ReleaseSha256 $filePath) -ne $Spec.sha256) {
        throw "SHA-256 mismatch: $Name. Do not run the installer."
    }
    Write-Host "Verified $Name"
}

foreach ($asset in $releaseManifest.downloads.PSObject.Properties) {
    Assert-ReleaseFile $asset.Name $asset.Value
}
$outputPath = Join-Path $PSScriptRoot 'Thmiuler-1.bin'
if (Test-Path -LiteralPath $outputPath) {
    Assert-ReleaseFile 'Thmiuler-1.bin' $releaseManifest.originals.'Thmiuler-1.bin'
    Write-Host 'Installer data is already complete. Run Thmiuler.exe when ready.'
    exit 0
}
$tempPath = Join-Path $PSScriptRoot ('Thmiuler-1.bin.joining-' + [guid]::NewGuid().ToString('N'))
try {
    $outputStream = [System.IO.File]::Open($tempPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    try {
        foreach ($partName in @('Thmiuler-1.bin.part01', 'Thmiuler-1.bin.part02')) {
            $inputStream = [System.IO.File]::OpenRead((Join-Path $PSScriptRoot $partName))
            try { $inputStream.CopyTo($outputStream, 8388608) } finally { $inputStream.Dispose() }
        }
    } finally { $outputStream.Dispose() }
    $expected = $releaseManifest.originals.'Thmiuler-1.bin'
    if ((Get-Item -LiteralPath $tempPath).Length -ne [long]$expected.size -or
        (Get-ReleaseSha256 $tempPath) -ne $expected.sha256) {
        throw 'Reassembled BIN failed verification. Do not run the installer.'
    }
    Move-Item -LiteralPath $tempPath -Destination $outputPath
    Write-Host 'Verified: Thmiuler.exe, Thmiuler-1.bin and Thmiuler-2.bin.'
    Write-Host 'Ready. Run Thmiuler.exe to start setup.'
} finally {
    if (Test-Path -LiteralPath $tempPath -PathType Leaf) { Remove-Item -LiteralPath $tempPath }
}
