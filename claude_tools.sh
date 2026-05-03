#!/bin/bash

# Function to list sessions and resume interactively
cr() {
    local CLAUDE_DIR="$HOME/.claude"
    local SESSION_ENV_DIR="$CLAUDE_DIR/session-env"
    local HISTORY_FILE="$CLAUDE_DIR/history.jsonl"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    # Check for dependencies
    local HAS_JQ=$(command -v jq)
    local HAS_FZF=$(command -v fzf)

    # Collect session data
    local SESSIONS_DATA=""
    
    # Get directories sorted by modification time
    while read -r FOLDER_PATH; do
        local FOLDER_NAME=$(basename "$FOLDER_PATH")
        local MOD_DATE=$(date -r "$FOLDER_PATH" "+%m/%d %H:%M")
        local DISPLAY_NAME="Unknown Session"

        if [ -f "$HISTORY_FILE" ]; then
            if [ -n "$HAS_JQ" ]; then
                # Use jq for accurate JSON parsing
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | jq -r --arg id "$FOLDER_NAME" 'select(.sessionId == $id or .display == $id) | .display' | tail -n 1)
            else
                # Simple sed fallback if jq is missing
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | tail -n 1 | sed -n 's/.*"display":"\([^"]*\)".*/\1/p')
            fi
        fi

        [ -z "$DISPLAY_NAME" ] && DISPLAY_NAME="Unknown Session"
        
        # Format: ID | Date | Prompt
        SESSIONS_DATA+="${FOLDER_NAME} | ${MOD_DATE} | ${DISPLAY_NAME}\n"
    done < <(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)

    if [ -z "$SESSIONS_DATA" ]; then
        echo -e "\e[31mNo sessions found.\e[0m"
        return 0
    fi

    local SELECTED_LINE=""
    if [ -n "$HAS_FZF" ]; then
        # Premium experience with fzf
        SELECTED_LINE=$(echo -e "$SESSIONS_DATA" | fzf --ansi --header "--- Select Claude Session to Resume ---" --reverse)
    else
        # Fallback to standard Bash select
        echo -e "\e[36m--- Select Claude Session to Resume ---\e[0m"
        local OLD_PS3=$PS3
        PS3="Enter number (or Ctrl+C): "
        
        # Use an array for 'select'
        IFS=$'\n' read -rd '' -a MENU_ARRAY <<< "$SESSIONS_DATA"
        select OPT in "${MENU_ARRAY[@]}"; do
            if [ -n "$OPT" ]; then
                SELECTED_LINE=$OPT
                break
            else
                echo "Invalid selection."
            fi
        done
        PS3=$OLD_PS3
    fi

    if [ -n "$SELECTED_LINE" ]; then
        local SELECTED_ID=$(echo "$SELECTED_LINE" | cut -d'|' -f1 | tr -d ' ')
        echo -e "\e[32mResuming session: $SELECTED_ID...\e[0m"
        claude --resume "$SELECTED_ID"
    fi
}

# Alias
alias cr='cr'
