return {
  'RRethy/base16-nvim',
  config = function()
    local is_wsl = vim.fn.getenv 'WSL_DISTRO_NAME' ~= vim.NIL

    vim.cmd 'colorscheme base16-default-dark'

    if is_wsl then
      local transparent_groups = {
        'Normal',
        'NormalNC',
        'NormalFloat',
        'FloatBorder',
        'SignColumn',
        'EndOfBuffer',
        'LineNr',
        'CursorLineNr',
        'FoldColumn',
        'WinSeparator',
        'StatusLine',
        'StatusLineNC',
        'TelescopeNormal',
        'TelescopeBorder',
        'TelescopePromptNormal',
        'TelescopePromptBorder',
        'TelescopeResultsNormal',
        'TelescopeResultsBorder',
        'TelescopePreviewNormal',
        'TelescopePreviewBorder',
        'TelescopeSelection',
      }

      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = 'none' })
      end
    end
  end,
}
