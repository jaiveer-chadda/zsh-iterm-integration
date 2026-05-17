#!/usr/bin/env zsh


iterm2::shell_level() {
  # If shell level's at 1, there's no need to show anything
  local shell_lvl=
  # But if it's any higher than 1, display the configured output
  if (( SHLVL != 1 )) shell_lvl="SHLVL: $SHLVL"

  echo "$shell_lvl"
}
