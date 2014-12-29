## zgen

A lightweight plugin manager for ZSH inspired by Antigen. Our goal is to have a minimal overhead when starting up the shell because nobody likes waiting. The script generates a static init.zsh file which does nothing but sources your plugins and appends them to fpath. The downside is that you have to update your plugins manually.

My current zgen setup takes 208ms to load where Antigen takes 1324ms with the same plugins.

### Usage

#### Clone and run oh-my-zsh
    zgen oh-my-zsh
    
#### Run a script from oh-my-zsh
    zgen oh-my-zsh <script>

#### Clone the repo and run a script
    zgen load <github repo> [script] [branch]

#### Clone the repo, then add it to `fpath`
    zgen completions <github repo> [subdirectory] [branch]
This also works with an optional `subdirectory`. Useful for repositories that don't have proper plugin support like `zsh-users/zsh-completions`.

#### Save all loaded scripts into an init script
    zgen save
We do this so they'll get run each time you source zgen.

#### Check for init script
    zgen saved
Returns 0 if an init script exists

#### Update zgen framework
    zgen selfupdate

#### Update all repositories and remove the init script
    zgen update

### Example .zshrc

```zsh
# load zgen
source "${HOME}/proj/zgen/zgen.zsh"

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load /path/to/super-secret-private-plugin

    # completion-only repositories. Add optional path argument to specify
    # what subdirectory of the repository to add to your fpath.
    zgen completions zsh-users/zsh-completions src

    # theme
    zgen oh-my-zsh themes/arrow

    # save all to init script
    zgen save
fi
```
