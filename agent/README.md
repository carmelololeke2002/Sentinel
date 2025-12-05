# Antivirus agent

Small example agent for the Antivirus project. The agent is a Rust binary built with `cargo`.

Build notes (Windows)
- By default Rust uses the MSVC toolchain on Windows which requires the Microsoft linker `link.exe` provided by Visual Studio Build Tools (Desktop development with C++ workload).
- If you see error `link.exe not found`, install the Build Tools for Visual Studio (https://visualstudio.microsoft.com/fr/downloads/) and select "Desktop development with C++".

Alternative on Windows
- You can use the GNU toolchain (mingw) instead of MSVC. Install MSYS2 and the mingw-w64 toolchain and then use the `stable-x86_64-pc-windows-gnu` toolchain with rustup.

Build on Linux (or CI)
- The GitHub Actions workflow `.github/workflows/ci-build.yml` builds the agent for Linux and Windows and uploads the release artifacts.

Quick local build commands
```powershell
cd C:\antivirus\agent
# Linux / macOS / Windows (with MSVC or GNU correctly installed)
cargo build --release

# run
.
target\release\antivirus-agent.exe --help
```

If you want, I can add cross-compilation scripts or a release workflow to create zips/releases automatically.
