# Go Language Installer

> **go.dev** is not accessible in some countries. This repository provides an alternative way to download and install Go (Golang) directly.

We mirror official Go release binaries in the [releases](./releases/) folder of this repository so you can download and install Go without needing access to `go.dev` or `dl.google.com`.

---

## Available Releases

| File | OS | Arch |
|------|----|------|
| `go1.26.0.linux-amd64.tar.gz` | Linux | x86-64 |
| `go1.26.0.linux-arm64.tar.gz` | Linux | ARM64 |
| `go1.26.0.windows-amd64.zip` | Windows | x86-64 |
| `go1.26.0.windows-arm64.zip` | Windows | ARM64 |
| `go1.26.0.darwin-amd64.tar.gz` | macOS | x86-64 (Intel) |
| `go1.26.0.darwin-arm64.tar.gz` | macOS | ARM64 (Apple Silicon) |

---

## Quick Install (One-Liner)

### Linux / macOS (amd64)

```bash
curl -fsSL https://raw.githubusercontent.com/TheWation/GoInstaller/master/install.sh | bash
```

Or using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/TheWation/GoInstaller/master/install.sh | bash
```

**Manual one-liner** (downloads from this repo's releases folder and installs):

```bash
curl -fsSL https://raw.githubusercontent.com/TheWation/GoInstaller/master/releases/go1.26.0.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf - && echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile && source ~/.profile && go version
```

### Windows (PowerShell — Run as Administrator)

```powershell
irm https://raw.githubusercontent.com/TheWation/GoInstaller/master/install.ps1 | iex
```

**Manual one-liner** (PowerShell — Run as Administrator):

```powershell
$env:GOZIP="$env:TEMP\go.zip"; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TheWation/GoInstaller/master/releases/go1.26.0.windows-amd64.zip" -OutFile $env:GOZIP; Expand-Archive -Path $env:GOZIP -DestinationPath "C:\Program Files" -Force; [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Go\bin", "Machine"); $env:Path += ";C:\Program Files\Go\bin"; Remove-Item $env:GOZIP; go version
```

---

## Manual Installation

### Linux

1. **Download** the archive from this repository:

   ```bash
   curl -fsSLO https://raw.githubusercontent.com/TheWation/GoInstaller/master/releases/go1.26.0.linux-amd64.tar.gz
   ```

2. **Remove any previous Go installation** and extract the archive:

   ```bash
   sudo rm -rf /usr/local/go
   sudo tar -C /usr/local -xzf go1.26.0.linux-amd64.tar.gz
   ```

3. **Add Go to your PATH** by appending this to `~/.profile` (or `~/.bashrc` / `~/.zshrc`):

   ```bash
   export PATH=$PATH:/usr/local/go/bin
   ```

4. **Apply changes**:

   ```bash
   source ~/.profile
   ```

5. **Verify**:

   ```bash
   go version
   ```

### Windows

1. **Download** the zip from this repository (PowerShell):

   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TheWation/GoInstaller/master/releases/go1.26.0.windows-amd64.zip" -OutFile "$env:TEMP\go.zip"
   ```

2. **Remove any previous Go installation** and extract:

   ```powershell
   Remove-Item -Recurse -Force "C:\Program Files\Go" -ErrorAction SilentlyContinue
   Expand-Archive -Path "$env:TEMP\go.zip" -DestinationPath "C:\Program Files" -Force
   ```

3. **Add Go to your system PATH** (requires Administrator):

   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Go\bin", "Machine")
   ```

4. **Verify** (open a new terminal):

   ```powershell
   go version
   ```

### macOS

1. **Download** the archive:

   ```bash
   curl -fsSLO https://raw.githubusercontent.com/TheWation/GoInstaller/master/releases/go1.26.0.darwin-arm64.tar.gz
   ```

   > Use `darwin-amd64` for Intel Macs.

2. **Remove any previous Go installation** and extract:

   ```bash
   sudo rm -rf /usr/local/go
   sudo tar -C /usr/local -xzf go1.26.0.darwin-arm64.tar.gz
   ```

3. **Add Go to your PATH** (append to `~/.zprofile`):

   ```bash
   export PATH=$PATH:/usr/local/go/bin
   ```

4. **Verify**:

   ```bash
   go version
   ```

---

## Automated Install Scripts

| Script | Platform | Description |
|--------|----------|-------------|
| [`install.sh`](./install.sh) | Linux / macOS | Bash script — auto-detects OS & arch, downloads and installs Go |
| [`install.ps1`](./install.ps1) | Windows | PowerShell script — auto-detects arch, downloads and installs Go |

---

## Updating Go

To update Go to a newer version, simply re-run the installer script or repeat the manual steps with the new version archive. The scripts automatically remove the previous installation before installing the new version.

---

## Setting GOPATH (Optional)

By default, Go uses `$HOME/go` (Linux/macOS) or `%USERPROFILE%\go` (Windows) as the workspace. You can customize it:

**Linux / macOS:**

```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

**Windows (PowerShell):**

```powershell
[Environment]::SetEnvironmentVariable("GOPATH", "$env:USERPROFILE\go", "User")
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\go\bin", "User")
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `go: command not found` | Make sure `/usr/local/go/bin` is in your `PATH` and restart your terminal |
| Permission denied on Linux | Use `sudo` for extracting to `/usr/local` |
| Windows PATH not updating | Open a **new** terminal after setting the environment variable |
| Wrong architecture | Check with `uname -m` (Linux/macOS) or `$env:PROCESSOR_ARCHITECTURE` (Windows) |

---

## License

The Go binaries are distributed under the [Go License](https://go.dev/LICENSE). This repository only mirrors official releases for accessibility.
