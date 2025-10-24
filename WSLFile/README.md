
# WSLFile  <span style="color: #409EFF; font-size: 0.6em; font-style: italic;"> - Productivity Script</span>

## ℹ️ Introduction

**WSLFile** is a Docker-like file designed to describe and install a WSL environment. It is primarily used to create WSL development stack templates, but it can be adapted for various other use cases.

*For a sample WSL development stack using this, see: [here](https://github.com/NicoJanE/PY-Flask-FastApi-Template-WSL-Stack) and [specific setup instructions here](https://nicojane.github.io/PY-Flask-FastApi-Template-WSL-Stack/Howtos/Setup).*<br>

## ✅ Requirements

- Windows 10 or 11
- WSL 2.6.1.0
- PowerShell 5.1 or 7.3

<br>

## 🛠️ WSLFile Syntax

The WSLFile supports the following syntax:

- Set distribution properties:
  - `DISTRO [name]`: Specifies the WSL distribution to use or a new WSL distribution to create.
  - `USER [name]`: Specifies the username in the WSL distribution.
  - `WORKDIR [name]`: Specifies the working directory in the WSL distribution.
  - Create a new Debian (Trixie) WSL: `DISTRO_DEBIAN_NEW --web-download --Location [C:\WSLDist\test2]`
- Execute a task in the WSL as sudo: `RUN sudo [task]`
- Execute a task in the WSL: `RUN [task]`
- Copy a file: `COPY [source file] [destination file]`
  - Use `~/` to direct the file to the user's home directory.
- Copy a directory with files (recursive): `COPY [source directory]`
  - Use `~/` to direct the directories/files to the user's home directory.
- Set an environment variable in the WSL: `ENV MY_VAR1=HelloWorld today1`

### Known Issues

1. The `RUN` action combined with `echo` has issues. For example, attempting to return a WSL environment variable with `RUN Value=$MY_VAR` will not return the value. Don't rely on the echo command.

## 🏃‍♂️ Running and Processing a WSLFile

Use one of these commands:

- `powershell.exe -File .\wsl-parser.ps1` — Reads and processes the file named `WSLFile` in the current directory.
- `powershell.exe -File .\wsl-parser.ps1 [path\to\your\WSLFile]` — Uses an alternative WSLFile.
- Optionally, set PowerShell permissions or use the option `-ExecutionPolicy Bypass`: `powershell.exe -ExecutionPolicy Bypass -File .\wsl-parser.ps1`

---

<br>

<details>  
  <summary class="clickable-summary">
  <span  class="summary-icon"></span> <!-- Square Symbol -->
  <b>Appendix I: Using VS Code with WSL</b>
  </summary> <!-- On same line is failure -->
  
To use VS Code in combination with WSL (development stack):

**First time**

1. Install VS Code in the host and the Remote WSL extension (Remote - WSL).
2. Ensure only one WSL is running to prevent issues.
3. In Windows VS Code: Press F1 -> 'Remote-WSL: New Window'.
4. Open the WSL folder in the VS Code window.

**For subsequent uses**:

1. Ensure only one WSL is running (check the default WSL!).
2. From the WSL terminal, type: `code .` to open a new VS Code window connected to the WSL.
3. In VS Code: Press F1 -> 'Remote-WSL: New Window'.
4. Open the WSL folder in the VS Code window.

*To set your WSL as default, use: `wsl --set-default [Distr-name]`*

</details>

<details>  
  <summary class="clickable-summary">
  <span  class="summary-icon"></span> <!-- Square Symbol -->
  <b>Appendix II: Packaging the script as an .exe</b>
  </summary> <!-- On same line is failure -->
  

To wrap your .ps1 script into an .exe so that the script can be added to a folder in your PATH and used like any executable file, follow these steps:

1. Install (one time) the ps2exe module by running this from your CLI:  
  `Install-Module -Name ps2exe -Scope CurrentUser`
2. Then run this command against the script file:  
  `ps2exe MyScript.ps1 MyScript.exe`
3. After that, copy `MyScript.exe` to a folder in your PATH and you can use it like any other executable.

</details>

<br><br>
<small><small>version 0.2</small></small>
