#!/bin/bash

# lsf — List Claude session folders, sorted by most recently modified
lsf() {
    local SESSION_ENV_DIR="$HOME/.claude/session-env"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    echo -e "\e[36mClaude Sessions (sorted by last modified):\e[0m"
    local dirs
    dirs=$(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)
    if [ -z "$dirs" ]; then
        echo "No sessions found."
        return 0
    fi

    while read -r d; do
        local name mod
        name=$(basename "$d")
        mod=$(date -r "$d" "+%m/%d %H:%M")
        printf "%-44s %s\n" "${name:0:40}" "$mod"
    done <<< "$dirs"
}

# cr — Select and resume a Claude session interactively
cr() {
    local CLAUDE_DIR="$HOME/.claude"
    local SESSION_ENV_DIR="$CLAUDE_DIR/session-env"
    local HISTORY_FILE="$CLAUDE_DIR/history.jsonl"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Error: whiptail is required for cr. Install whiptail and try again."
        return 1
    fi

    local HAS_JQ=$(command -v jq)

    local SESSIONS_DATA=""

    while read -r FOLDER_PATH; do
        local FOLDER_NAME=$(basename "$FOLDER_PATH")
        local MOD_DATE=$(date -r "$FOLDER_PATH" "+%m/%d %H:%M")
        local DISPLAY_NAME="Unknown Session"

        if [ -f "$HISTORY_FILE" ]; then
            if [ -n "$HAS_JQ" ]; then
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | jq -r --arg id "$FOLDER_NAME" 'select(.sessionId == $id or .display == $id) | .display' 2>/dev/null | tail -n 1)
            else
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | tail -n 1 | sed -n 's/.*"display":"\([^"]*\)".*/\1/p')
            fi
        fi

        [ -z "$DISPLAY_NAME" ] && DISPLAY_NAME="Unknown Session"

        SESSIONS_DATA+="${FOLDER_NAME} | ${MOD_DATE} | ${DISPLAY_NAME}\n"
    done < <(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)

    if [ -z "$SESSIONS_DATA" ]; then
        echo -e "\e[31mNo sessions found.\e[0m"
        return 0
    fi

    local MENU_ITEMS=()
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local item_id item_label
        item_id=$(printf '%s' "$line" | cut -d'|' -f1 | xargs)
        item_label=$(printf '%s' "$line" | cut -d'|' -f2- | sed 's/^ *//')
        MENU_ITEMS+=("$item_id" "$item_label")
    done <<< "$(echo -e "$SESSIONS_DATA")"

    local SELECTED_ID
    SELECTED_ID=$(whiptail \
        --title "Claude Session Resume" \
        --menu "Select Claude session to resume" \
        22 120 12 \
        "${MENU_ITEMS[@]}" \
        3>&1 1>&2 2>&3
    )

    local STATUS=$?
    if [ $STATUS -ne 0 ]; then
        return 0
    fi

    if [ -n "$SELECTED_ID" ]; then
        echo -e "\e[32mResuming session: $SELECTED_ID...\e[0m"
        claude --resume "$SELECTED_ID"
    fi
}
#!/bin/bash

# lsf — List Claude session folders, sorted by most recently modified
lsf() {
    local SESSION_ENV_DIR="$HOME/.claude/session-env"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    echo -e "\e[36mClaude Sessions (sorted by last modified):\e[0m"
    local dirs
    dirs=$(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)
    if [ -z "$dirs" ]; then
        echo "No sessions found."
        return 0
    fi

    while read -r d; do
        local name mod
        name=$(basename "$d")
        mod=$(date -r "$d" "+%m/%d %H:%M")
        printf "%-44s %s\n" "${name:0:40}" "$mod"
    done <<< "$dirs"
}

# cr — Select and resume a Claude session interactively
cr() {
    local CLAUDE_DIR="$HOME/.claude"
    local SESSION_ENV_DIR="$CLAUDE_DIR/session-env"
    local HISTORY_FILE="$CLAUDE_DIR/history.jsonl"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Error: whiptail is required for cr. Install whiptail and try again."
        return 1
    fi

    local HAS_JQ=$(command -v jq)

    local SESSIONS_DATA=""

    while read -r FOLDER_PATH; do
        local FOLDER_NAME=$(basename "$FOLDER_PATH")
        local MOD_DATE=$(date -r "$FOLDER_PATH" "+%m/%d %H:%M")
        local DISPLAY_NAME="Unknown Session"

        if [ -f "$HISTORY_FILE" ]; then
            if [ -n "$HAS_JQ" ]; then
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | jq -r --arg id "$FOLDER_NAME" 'select(.sessionId == $id or .display == $id) | .display' 2>/dev/null | tail -n 1)
            else
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | tail -n 1 | sed -n 's/.*"display":"\([^"]*\)".*/\1/p')
            fi
        fi

        [ -z "$DISPLAY_NAME" ] && DISPLAY_NAME="Unknown Session"

        SESSIONS_DATA+="${FOLDER_NAME} | ${MOD_DATE} | ${DISPLAY_NAME}\n"
    done < <(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)

    if [ -z "$SESSIONS_DATA" ]; then
        echo -e "\e[31mNo sessions found.\e[0m"
        return 0
    fi

    local MENU_ITEMS=()
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local item_id item_label
        item_id=$(printf '%s' "$line" | cut -d'|' -f1 | xargs)
        item_label=$(printf '%s' "$line" | cut -d'|' -f2- | sed 's/^ *//')
        MENU_ITEMS+=("$item_id" "$item_label")
    done <<< "$(echo -e "$SESSIONS_DATA")"

    local SELECTED_ID
    SELECTED_ID=$(whiptail \
        --title "Claude Session Resume" \
        --menu "Select Claude session to resume" \
        22 120 12 \
        "${MENU_ITEMS[@]}" \
        3>&1 1>&2 2>&3
    )

    local STATUS=$?
    if [ $STATUS -ne 0 ]; then
        return 0
    fi

    if [ -n "$SELECTED_ID" ]; then
        echo -e "\e[32mResuming session: $SELECTED_ID...\e[0m"
        claude --resume "$SELECTED_ID"
    fi
}
#!/bin/bash

# lsf — List Claude session folders, sorted by most recently modified
lsf() {
    local SESSION_ENV_DIR="$HOME/.claude/session-env"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    echo -e "\e[36mClaude Sessions (sorted by last modified):\e[0m"
    local dirs
    dirs=$(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)
    if [ -z "$dirs" ]; then
        echo "No sessions found."
        return 0
    fi

    while read -r d; do
        local name mod
        name=$(basename "$d")
        mod=$(date -r "$d" "+%m/%d %H:%M")
        printf "%-44s %s\n" "${name:0:40}" "$mod"
    done <<< "$dirs"
}

# cr — Select and resume a Claude session interactively
cr() {
    local CLAUDE_DIR="$HOME/.claude"
    local SESSION_ENV_DIR="$CLAUDE_DIR/session-env"
    local HISTORY_FILE="$CLAUDE_DIR/history.jsonl"

    if [ ! -d "$SESSION_ENV_DIR" ]; then
        echo -e "\e[31mError: Session directory not found at $SESSION_ENV_DIR\e[0m"
        return 1
    fi

    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Error: whiptail is required for cr. Install whiptail and try again."
        return 1
    fi

    local HAS_JQ=$(command -v jq)

    local SESSIONS_DATA=""

    while read -r FOLDER_PATH; do
        local FOLDER_NAME=$(basename "$FOLDER_PATH")
        local MOD_DATE=$(date -r "$FOLDER_PATH" "+%m/%d %H:%M")
        local DISPLAY_NAME="Unknown Session"

        if [ -f "$HISTORY_FILE" ]; then
            if [ -n "$HAS_JQ" ]; then
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | jq -r --arg id "$FOLDER_NAME" 'select(.sessionId == $id or .display == $id) | .display' 2>/dev/null | tail -n 1)
            else
                DISPLAY_NAME=$(grep "$FOLDER_NAME" "$HISTORY_FILE" | tail -n 1 | sed -n 's/.*"display":"\([^"]*\)".*/\1/p')
            fi
        fi

        [ -z "$DISPLAY_NAME" ] && DISPLAY_NAME="Unknown Session"

        SESSIONS_DATA+="${FOLDER_NAME} | ${MOD_DATE} | ${DISPLAY_NAME}\n"
    done < <(ls -dt "$SESSION_ENV_DIR"/* 2>/dev/null)

    if [ -z "$SESSIONS_DATA" ]; then
        echo -e "\e[31mNo sessions found.\e[0m"
        return 0
    fi

    local MENU_ITEMS=()
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local item_id item_label
        item_id=$(printf '%s' "$line" | cut -d'|' -f1 | xargs)
        item_label=$(printf '%s' "$line" | cut -d'|' -f2- | sed 's/^ *//')
        MENU_ITEMS+=("$item_id" "$item_label")
    done <<< "$(echo -e "$SESSIONS_DATA")"

    local SELECTED_ID
    SELECTED_ID=$(whiptail \
        --title "Claude Session Resume" \
        --menu "Select Claude session to resume" \
        22 120 12 \
        "${MENU_ITEMS[@]}" \
        3>&1 1>&2 2>&3
    )

    local STATUS=$?
    if [ $STATUS -ne 0 ]; then
        return 0
    fi

    if [ -n "$SELECTED_ID" ]; then
        echo -e "\e[32mResuming session: $SELECTED_ID...\e[0m"
        claude --resume "$SELECTED_ID"
    fi
}
