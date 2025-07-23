#!/usr/bin/env bash
osc () { printf "\033]1337;%s\007" "$1"; }

osc "split=right"; sleep 0.1
osc "goto_split=right"; sleep 0.1
osc "split=down"; sleep 0.1

osc "goto_split=left"; printf "nvim\n"
osc "goto_split=top"; printf "echo '▶️ Starte Claude manuell hier... '\n"
osc "goto_split=bottom"; printf "echo '▶️ Playwright MCP sollte laufen, falls konfiguriert.'\n"

tail -f /dev/null
