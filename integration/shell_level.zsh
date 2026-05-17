#!/usr/bin/env zsh

iterm2::shell_level() {
  # If shell level's at 1, there's no need to show anything
  # But if it's any higher than 1, display `$SHLVL`
  if (( SHLVL != 1 )) echo -n "SHLVL: $SHLVL"
}
