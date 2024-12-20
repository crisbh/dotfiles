<h1 align="center">dotfiles repo</h1>

<div align="center"><p>
    <a href="https://github.com/crisbh/dotfiles/pulse">
      <img src="https://img.shields.io/github/last-commit/crisbh/dotfiles?color=%4dc71f&label=Last%20Commit&logo=github&style=flat-square"/>
    </a>
</p>
</div>

## Overview

Repo with the dotfiles I use in my own (local) machine. These aim at setting up a smooth daily workflow.

My setup includes:
- shell: `zsh`
- terminal: `kitty`
- editor: `neovim`
- PDF reader: `zathura`
- terminal session manager: `tmux`
- tiling windows manager: `amethyst` (macOS)

## Installation

I use [`GNU stow`](https://www.gnu.org/software/stow/) to deploy the various dotfiles from this repo in the form of
symlinks. For this, go into the repo's directory and run

```shell
stow -t $HOME .
```

Notice that this method requires that the file structure in this repo mimicks the one in
the user's home directory.

Alternatively, just run the provided `install` bash script as
```shell
bash install.sh
```
