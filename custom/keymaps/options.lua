print("Custom Options")
-- Fold options
vim.opt.foldmethod = "expr"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

vim.opt.foldlevel = 5
