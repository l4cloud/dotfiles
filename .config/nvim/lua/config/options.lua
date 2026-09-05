vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.cursorline = false
vim.opt.scrolloff = 15
vim.opt.showmode = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2
vim.opt.cmdheight = 0
vim.opt.relativenumber = true

local is_wsl = vim.fn.getenv 'WSL_DISTRO_NAME' ~= vim.NIL
if is_wsl then
  vim.opt.termguicolors = true
end

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-show diagnostics when hovering over a line with an error
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  desc = 'Show diagnostics on hover',
  group = vim.api.nvim_create_augroup('kickstart-diagnostic-hover', { clear = true }),
  callback = function()
    if vim.fn.mode() ~= 'n' then
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    if #vim.diagnostic.get(bufnr, { lnum = line }) > 0 then
      vim.diagnostic.open_float {
        focusable = false,
        lnum = line,
        relative = 'win',
        anchor = 'SE',
        row = 0,
        col = 0,
      }
    end
  end,
})
