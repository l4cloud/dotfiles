return {
  'RRethy/base16-nvim',
  config = function()
    local is_wsl = vim.fn.getenv 'WSL_DISTRO_NAME' ~= vim.NIL
    if is_wsl then
      vim.cmd 'colorscheme rose-pine'
    else
      vim.cmd 'colorscheme base16-default-dark'
    end
  end,
}
