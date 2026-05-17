#!/usr/bin/env zsh

source "${0:h}/date_time.zsh"
source "${0:h}/shell_level.zsh"

iterm2_print_user_vars() {
  # Send all the variables to iTerm
  iterm2_set_user_var shell_level "$( iterm2::shell_level )"
  iterm2_set_user_var date_time   "$( iterm2::date_time   )"
}
