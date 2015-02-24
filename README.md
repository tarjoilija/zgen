## zgen

A lightweight plugin manager for ZSH inspired by Antigen. Our goal is to have a minimal overhead when starting up the shell because nobody likes waiting. The script generates a static init.zsh file which does nothing but sources your plugins and appends them to fpath. The downside is that you have to update your plugins manually.

My current zgen setup takes 208ms to load where Antigen takes 1324ms with the same plugins.

### Usage

#### Load oh-my-zsh base
    zgen oh-my-zsh

#### Load oh-my-zsh plugins
    zgen oh-my-zsh <location>
This is a shortcut for `zgen load`.

#### Load plugins and completions
    zgen load <repo> [location] [branch]
Similar to `antigen bundle`. It tries to source any scripts from `location`. If none found, it adds `location` to `$fpath`.

- `repo`
    - github 'user/repository' or path to a local repository
- `location`
    - relative path to a script/folder
    - useful for repositories that don't have proper plugin support like `zsh-users/zsh-completions`
- `branch`
    - for those who don't use the master branch

#### Save all loaded scripts into an init script
    zgen save
We do this so they'll get run each time you source zgen.

#### Check for an init script
    zgen saved
Returns 0 if an init script exists.

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

    # completions
    zgen load zsh-users/zsh-completions src

    # theme
    zgen oh-my-zsh themes/arrow

    # save all to init script
    zgen save
fi
```

## Other resources

The [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) list contains many zgen-compatible zsh plugins & themes that you may find useful.
