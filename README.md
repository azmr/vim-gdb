# gdb.vim
Open GDB from vim with set breakpoints (more to come)

(only tested with gVim on Windows so far)


## Installation

As with most other plugins, [pathogen](https://github.com/tpope/vim-pathogen) and [vundle](https://github.com/VundleVim/Vundle.vim) should work fine.


## Usage

```vim
:QuickGDB(args)
```
This will open GDB in a console and set breakpoints at the args.

If no args are given, a breakpoint will be set at the current line.


### Argument format

You can input as many arguments as you like up to 20 (the max Vim allows).


#### Line Numbers

```vim
:QuickGDB(24, 125, 76)
```

This will set breakpoints at the stated lines in the current file.


#### Buffers

```vim
:QuickGDB('b#', 'buf 6', 'buffer main:32')
```

Assuming the buffer name is valid as per Vim's normal rules,
if a number is appended to the buffer name in the format `:123`,
the breakpoint will be set at that line number in the file corresponding
to that buffer

If no number is appended, you will be prompted to interactively input one.

If no number is given when prompted, or the number at any point is given
as `0`, a breakpoint will be set at the current line in that buffer (which
you can see with `:ls`).


#### Files

```vim
:QuickGDB('E:/Documents/Code/Rust/cool_program/src/main.rs:32', 'subfolder/code.rs:10')
```

The file can be given in an absolute form or relative to the current working directory.

The line number must be appended.


### Setup

You may find it helpful to include a mapping in your `.vimrc` such as the following:
```vim
" call QuickGDB with the option of arguments
nnoremap <leader>g :call QuickGDB()<left>
```


## Credits

Created by Andrew Reece
Helped in large part by 'Learn Vimscript the Hard Way' by Steve Losh
