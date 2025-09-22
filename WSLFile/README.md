# What is WSLFile?

**WSLFile** is a Docker-like file designed to describe and install a WSL environment by creating a WSLFile. It is primarily used to create WSL development stack templates, but it can be adapted for various other use cases.


*For a sample WSL development stack see: [todo]()*

<br>

## Requirements
- Windows 10 or 11
- WSL 2.6.1.0
- Powershell 5.1 or 7.3

<br>

## WSLFile syntax

The WSLFIle support the following syntax:

- Set distribution properties:
  - `DISTRO [name]`: Specifies the WSL Distribution to use or a new WSL distribution to create.
  - `USER [name]`: Specifies the user name in the WSL distribution.
  - `WORKDIR [name]`: Specifies the working directory in the WSL distribution.
- Create a new Debian (Trixi) WSL: `DISTRO_DEBIAN_NEW --web-download --Location [C:\WSLDist\test2]`
- Execute a task in the WSL as sudo: `RUN sudo [task]`
- Execute a task in the WSL: `RUN [task]`
- Copy a file: `COPY [source file] [destination file]`
- Copy a directory with files (recursive): `COPY [source directory]`
- Set an environment variable in the WSL: `ENV MY_VAR1=HelloWorld today1`


### Known Issues
1. The `RUN` action combined with `echo` has issues. For example, attempting to return a WSL environment variable with `RUN Value=$MY_VAR` will not return the value. Don't relia on the echo command

<br>

## Running and Processing a WSL File

Use one of these commands:

- `powershell.exe -File .\wsl-parser.ps1`: Reads and processes the file `WSLFile`.
- `powershell.exe -File .\wsl-parser.ps1 WSLfile=[path\to\your\WSLfile_Python]`: Uses an alternative `WSLFile`.
- Optionally, set PowerShell permissions or use the option `-ExecutionPolicy Bypass`: `powershell.exe ExecutionPolicy Bypass -File .\wsl-parser.ps1`


---

<br>

<details>  
  <summary class="clickable-summary">
  <span  class="summary-icon"></span> <!-- Square Symbol -->
  <b>Appendix: Using VS Code with WSL</b>
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


<br><br>
<small><small>version 0.1 </small></small>