-- Version of 02.10.2022.
-- init.lua resolves all configuration dependencies.
require("szymon.set")
require("szymon.remap")
require("szymon.autocmd")
require("szymon.lsp")

-- Starts up NERDTree if no file arguments are given.
vim.cmd("autocmd VimEnter * if !argc() | NERDTree | only | endif")
