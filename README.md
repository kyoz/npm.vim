# npm.vim
> Work with NPM more easier in VIM

<p align="center">
  <img src="https://i.imgur.com/OBywzos.gif" width="800px">
</p>

## Introduction

This plugin help you install, maintain, update packages more easily inside vim.

It will auto detech and use which package manage you have installed (Prefer yarn if both installed cause it's seem faster).

## Install

Install with Vim Plug, other plugin managers is similar.

```
Plug 'banminkyoz/npm.vim'
```

## Usage

| Command               | Keymap      | Action |
| ---                   | ---         | ---    |
| NpmInit               |             | Init Npm for current folder |
| NpmInstall, NpmI      |             | Install provided package as dependency |
| NpmUninstall, NpmU    |             | Uninstall provided package and remove dependency |
| Npm, NpmLatest, NpmL  | \<leader\>n | Get lastest version of provided package (or package at cursor position if found) |
| NpmAll, NpmA          | \<leader\>N | Get all version of provided package (or package at cursor position if found) |

## License

MIT © [Kyoz](mailto:banminkyoz@gmail.com)
