# Windows installation

This release distributes the existing Windows x64 installer snapshot from 27 October 2026. Its main data file exceeds GitHub's per-asset limit, so that one file is delivered as two raw parts. Reassembly changes neither the installer nor its payload. This is not the separate Windows 7 distribution.

## Download every asset

Use the named assets under [the latest release](https://github.com/Redlargeforest/Thmiuler-Releases/releases/latest), not GitHub's automatic Source code archives. Save all files below in one folder with their original names.

| Download | Bytes |
| --- | ---: |
| `Thmiuler-1.bin.part01` | 1,800,000,000 |
| `Thmiuler-1.bin.part02` | 1,688,555,776 |
| `Thmiuler.exe` | 11,444,160 |
| `Thmiuler-2.bin` | 1,192,823,032 |
| `JoinInstaller.ps1` | 3,499 |
| `SHA256SUMS.txt` | Small text checksum list |

Allow at least 9 GB of free space for the downloads and reconstructed installer data, plus additional space for the installed application. Setup will report its installation space requirements.

## Verify and reconstruct

Inspect [JoinInstaller.ps1](../tools/JoinInstaller.ps1) if desired. In PowerShell, open the download folder and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\JoinInstaller.ps1
```

This invocation applies only to that process. The helper verifies the sizes and SHA-256 values of all four binary assets, joins the two parts, and verifies the reconstructed `Thmiuler-1.bin`. It does not start setup or alter an existing BIN. If verification fails, download the affected asset again before continuing.

When the helper reports success, run `Thmiuler.exe`. Keep these three files together while setup runs:

```text
Thmiuler.exe
Thmiuler-1.bin
Thmiuler-2.bin
```

The normal destination is `C:\Thmiuler`. Keep the installed application structure intact. For MCP setup, follow the [connection guide](MCP_QUICKSTART.md).

## Manual alternative

In **Command Prompt** in the download folder, concatenate the raw parts in order. Use this command only when `Thmiuler-1.bin` does not already exist:

```bat
copy /b Thmiuler-1.bin.part01+Thmiuler-1.bin.part02 Thmiuler-1.bin
```

Then verify all three original files in PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 .\Thmiuler.exe, .\Thmiuler-1.bin, .\Thmiuler-2.bin
```

Compare every value with the table below and `SHA256SUMS.txt` before running setup. To verify individual download parts, pass their names to `Get-FileHash` and compare against the same checksum list.

| Original installer file | Bytes | SHA-256 |
| --- | ---: | --- |
| `Thmiuler.exe` | 11,444,160 | `65a0fc95709e526b5e20348293fd1f50bcc6fc1cbf4147feb1db91e5a4b0933a` |
| `Thmiuler-1.bin` | 3,488,555,776 | `f235092eac13246969a09f7c839d604fbee971f6d7e3215e996842eaa12a7372` |
| `Thmiuler-2.bin` | 1,192,823,032 | `af10d4a63603ee573f92faaa88f87681c9dd00eaf3a11868cd3afb7a316fc149` |

The checksum list is also preserved in [checksums/2026.10.27.txt](../checksums/2026.10.27.txt). Checksums detect corrupted or mismatched files; obtain the installer and its checksum list from this official repository.

For product information and support, use [the official website](https://thmiuler.com.cn/).
