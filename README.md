
# Claude Tools Installation Guide

This guide explains how to install the `lsf` and `cr` commands for your PowerShell environment.

## Method 1: Permanent Installation (Recommended)

To make these commands available every time you open a terminal:

1.  **Open your PowerShell Profile** in Notepad:
    ```powershell
    notepad $PROFILE
    ```
    *(If it asks to create a new file, say **Yes**)*

2.  **Copy and Paste** the entire content of `claude_tools.ps1` into that file.

3.  **Save and Close** Notepad.

4.  **Restart your terminal** or run:
    ```powershell
    . $PROFILE
    ```

---

## Method 2: Temporary Load (Current Session Only)

If you only want to use the tools in your current terminal window:

1.  **Navigate** to the folder containing `claude_tools.ps1`.
2.  **Run** the following command:
    ```powershell
    . .\claude_tools.ps1
    ```

---

## Method 3: Linux / macOS Installation

If you are using Bash or Zsh on Linux or macOS:

1.  **Open your shell profile** (e.g., `~/.bashrc` or `~/.zshrc`):
    ```bash
    nano ~/.bashrc
    ```

2.  **Copy and Paste** the content of `claude_tools.sh` at the end of the file.

3.  **Source the file**:
    ```bash
    source ~/.bashrc
    ```

*Note: For the best experience on Linux, it is recommended to install `fzf` (interactive finder) and `jq` (JSON processor).*

---

## Available Commands

### 1. `lsf` (List Sessions)
Lists all Claude sessions in your `.claude\session-env` directory, sorted by the most recently modified.

### 2. `cr` (Claude Resume)
Opens an interactive menu showing your recent sessions with:
*   **Session IDs** (Shortened).
*   **Last Active Date/Time**.
*   **First Prompt/Display Name** (to easily identify what the session was about).

**Controls:**
*   Use **Up/Down Arrow Keys** to navigate.
*   Press **Enter** to resume the selected session.
*   Press **Esc** to cancel.

---

## Customization
The tool automatically detects your Claude directory using `$env:USERPROFILE\.claude`. 
If your sessions are stored in a custom location, you can modify the paths at the top of the functions in `claude_tools.ps1`.

