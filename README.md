zgen
====

A light plugin manager for zsh inspired by Antigen.

## Usage

`zgen load-oh-my-zsh` clone and run oh-my-zsh

`zgen load <github repo> <script>` clone the repo and run the script

`zgen save` save all loaded scripts into an init script so they'll get run each time you source zgen

`zgen update` update all repositories

## Example .zshrc using init script

    # load zgen
    source "${HOME}/proj/zgen/zgen.zsh"

    # check if there's an init script
    if [[ ! -f "${ZGEN_INIT}" ]]; then
        echo "no init script found; creating one"

        zgen load-oh-my-zsh

        # plugins
        zgen load zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting.zsh
        zgen load robbyrussell/oh-my-zsh plugins/git/git.plugin.zsh
        zgen load robbyrussell/oh-my-zsh plugins/npm/npm.plugin.zsh
        zgen load robbyrussell/oh-my-zsh plugins/pip/pip.plugin.zsh
        zgen load robbyrussell/oh-my-zsh plugins/command-not-found/command-not-found.plugin.zsh
        zgen load robbyrussell/oh-my-zsh plugins/sudo/sudo.plugin.zsh

        # theme
        zgen load robbyrussell/oh-my-zsh themes/arrow.zsh-theme

        # save all to init script
        zgen save
    fi

You could also just load plugins and save init script manually and just source zgen on zshrc.
