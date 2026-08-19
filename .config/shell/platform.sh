if [[ -z "${DOTFILES_PLATFORM:-}" ]]; then
  if [[ -n "${WSL_INTEROP:-}" ]] || [[ "$(uname -r 2>/dev/null)" == *[Mm]icrosoft* ]]; then
    DOTFILES_PLATFORM=wsl
  else
    DOTFILES_PLATFORM=linux
  fi
fi

export DOTFILES_PLATFORM

platform_config="$HOME/.config/shell/platform/$DOTFILES_PLATFORM.sh"
# shellcheck source=/dev/null
[[ -r "$platform_config" ]] && source "$platform_config"
unset platform_config
