## Maddison's neovim configuration

![nvim-conf screenshot](https://user-images.githubusercontent.com/21299126/159453973-ff39d626-d06a-412b-a12b-42143d6b7c5b.png)

This is my neovim configuration, cobbled together over the course of several
years.

There's a few things in here that are very specific to my setup/workflow, but
most of it should be platform/setup agnostic.

Enjoy!

### Setup

You probably don't want to use my configuration as-is, but if you _really_ want
to:

Assuming the directory doesn't yet exist, clone this repo to `$HOME/.config/nvim`:

```
$ git clone github.com/b0o/dotfiles-nvim ~/.config/nvim
```

Then open vim and run `:PackerInstall`.

To update plugins, use `:PackerUpdate`.
