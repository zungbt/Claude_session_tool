
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

