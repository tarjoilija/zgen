zgen
====

A light plugin manager for zsh inspired by Antigen.

## Usage

`zgen oh-my-zsh` clone and run oh-my-zsh

`zgen oh-my-zsh <script>` shortcut for the command below

`zgen load <github repo> <script>` clone the repo and run the script

`zgen save` save all loaded scripts into an init script so they'll get run each time you source zgen

`zgen update` update all repositories

## Example .zshrc

```zsh
# load zgen
source "${HOME}/proj/zgen/zgen.zsh"

# check if there's an init script
if [[ ! -f "${ZGEN_INIT}" ]]; then
    echo "no init script found; creating one"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/npm
    zgen oh-my-zsh plugins/pip
    zgen oh-my-zsh plugins/command-not-found
    zgen oh-my-zsh plugins/sudo
    zgen load zsh-users/zsh-syntax-highlighting

    # theme
    zgen oh-my-zsh themes/arrow.zsh-theme

    # save all to init script
    zgen save
fi
```
