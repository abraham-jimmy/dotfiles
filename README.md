# dotfiles

# How to init a bare repo for the first time: 
> git init --bare ~/.dotfiles
Make it so no files are tracked by default
> dotfiles config status.showUntrackedFiles no

Add alias to your .bashrc or .zshrc:
> alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

On a new system like:
> git clone --bare <git-repo-url> $HOME/.dotfiles
> alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
> dotfiles checkout
> dotfiles config --local status.showUntrackedFiles no

Then you can use it like:
> dotfiles add <file>
> dotfiles commit -m "Commit message"
> dotfiles push origin main
