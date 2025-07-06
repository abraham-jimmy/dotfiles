# dotfiles

# How to init a bare repo for the first time: 
Initialize the git repo in hidden files in your home folder
```bash
git init --bare ~/.dotfiles
```
Make it so no files are tracked by default
```bash
dotfiles config status.showUntrackedFiles no
```
Add alias to your .bashrc or .zshrc:
```bash
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
```

On a new system clone this repo with:
```bash
git clone --bare git@github.com:abraham-jimmy/dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
```

Then you can use it to update and add files like:
```bash
dotfiles add <file>
dotfiles commit -m "Commit message"
dotfiles push origin main
```
