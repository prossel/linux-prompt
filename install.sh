#!/bin/sh
set -eu

# Usage: sh install.sh [COLOR]
# Example: sh install.sh '#00BB00'
ACCENT=${1:-#00BB00}
case "$ACCENT" in
  \#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) ;;
  *) echo "Error: expected a color in '#RRGGBB' format." >&2; exit 2 ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  echo 'curl is required to install Starship.' >&2
  exit 1
fi

BIN="$HOME/.local/bin"
CONF_DIR="$HOME/.config"
mkdir -p "$BIN" "$CONF_DIR"

if ! command -v starship >/dev/null 2>&1 && ! [ -x "$BIN/starship" ]; then
  echo 'Installing Starship in ~/.local/bin ...'
  temp_script=$(mktemp)
  trap 'rm -f "$temp_script"' EXIT HUP INT TERM
  curl -fsSL https://starship.rs/install.sh -o "$temp_script"
  sh "$temp_script" -y -b "$BIN"
  rm -f "$temp_script"
  trap - EXIT HUP INT TERM
fi

CONF="$CONF_DIR/starship.toml"
if [ -f "$CONF" ] && ! grep -q '^# Managed by linux-prompt installer$' "$CONF"; then
  backup="$CONF.backup.$(date +%Y%m%d%H%M%S)"
  cp "$CONF" "$backup"
  echo "Previous Starship configuration backed up: $backup"
fi

cat > "$CONF" <<'TOML'
# Managed by linux-prompt installer
# Accent color: changed by rerunning install.sh with a new #RRGGBB
add_newline = true
format = """
[┌─](bold ACCENT_COLOR)$username[@](bold ACCENT_COLOR)$hostname[  ]()$directory$git_branch$git_status$cmd_duration
[└─](bold ACCENT_COLOR)$character
"""

[username]
show_always = true
format = '[$user](bold ACCENT_COLOR)'

[hostname]
ssh_only = false
format = '[$hostname](bold ACCENT_COLOR)'
trim_at = '.'

[directory]
format = '[$path](bold blue)'
truncation_length = 4
truncation_symbol = '…/'

[git_branch]
symbol = ' ⎇ '
format = '[$symbol$branch](bold purple)'

[git_status]
format = '([ $all_status$ahead_behind](bold yellow))'
conflicted = '='
ahead = '⇡'
behind = '⇣'
diverged = '⇕'
modified = '!'
staged = '+' 
untracked = '?'
deleted = '✘'
renamed = '»'
stashed = '$'

[cmd_duration]
min_time = 2000
format = ' [took $duration](dimmed yellow)'

[character]
success_symbol = '[>](bold ACCENT_COLOR)'
error_symbol = '[>](bold red)'
TOML
# ACCENT must be validated above before substitution.
sed "s/ACCENT_COLOR/$ACCENT/g" "$CONF" > "$CONF.tmp"
mv "$CONF.tmp" "$CONF"

# Add startup block once, preserving existing dotfiles.
START='# >>> linux-prompt >>>'
END='# <<< linux-prompt <<<' 
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || : > "$rc"
  if ! grep -Fq '# >>> linux-prompt locale >>>' "$rc"; then
    temp_rc=$(mktemp)
    {
      cat <<'RC'
# >>> linux-prompt locale >>>
if [ "${LANG-}" = C ]; then
  export LANG=C.UTF-8
fi
# <<< linux-prompt locale <<<
RC
      cat "$rc"
    } > "$temp_rc"
    cat "$temp_rc" > "$rc"
    rm -f "$temp_rc"
  fi
  if ! grep -Fq "$START" "$rc"; then
    cat >> "$rc" <<'RC'

# >>> linux-prompt >>>
export PATH="$HOME/.local/bin:$PATH"
if command -v starship >/dev/null 2>&1; then
  case "${BASH_VERSION-}${ZSH_VERSION-}" in
    '') ;;
    *) if [ -n "${BASH_VERSION-}" ]; then
         eval "$(starship init bash)"
       elif [ -n "${ZSH_VERSION-}" ]; then
         eval "$(starship init zsh)"
       fi ;;
  esac
fi
# <<< linux-prompt <<<
RC
  fi
done

if [ -f "$HOME/.bash_profile" ]; then
  bash_profile="$HOME/.bash_profile"
elif [ -f "$HOME/.profile" ]; then
  bash_profile="$HOME/.profile"
else
  bash_profile=
fi

if [ -n "$bash_profile" ]; then
  if grep -Ev '^[[:space:]]*#' "$bash_profile" |
    grep -Eq '(^|[;&[:space:]])(source|\.)[[:space:]]+([^#]*)(\$HOME/|~/)?\.bashrc([^[:alnum:]_]|$)'; then
    echo "The Bash profile $bash_profile already loads .bashrc."
  else
    source_line='if [ -n "${BASH_VERSION-}" ] && [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi'
    if [ -t 0 ] || [ -t 2 ]; then
      printf 'The Bash profile %s does not load .bashrc. Add the line? [y/N] ' "$bash_profile" >&2
      if [ -t 0 ]; then
        IFS= read -r answer || answer=
      else
        IFS= read -r answer </dev/tty || answer=
      fi
      case "$answer" in
        y|Y|yes|YES|Yes)
          printf '\n# Added by linux-prompt installer\n%s\n' "$source_line" >> "$bash_profile"
          echo "Added the .bashrc sourcing line to $bash_profile."
          ;;
        *)
          echo "No changes made to $bash_profile."
          ;;
      esac
    else
      printf 'Suggestion: add this line to %s to load .bashrc in Bash login shells:\n%s\n' \
        "$bash_profile" "$source_line"
    fi
  fi
fi

echo "Installation complete. Accent color: $ACCENT"
echo 'Open a new interactive shell (or run: exec bash / exec zsh).'
echo 'Note: this configuration applies only to the current user account.'
