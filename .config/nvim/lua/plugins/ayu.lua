return {
  'Shatur/neovim-ayu',
  config = function()
    require('ayu').setup {
      mirage = true, -- Use the mirage variant
      terminal = true, -- Let the theme manage terminal colors
      overrides = {
        Normal = { bg = 'None' },
        NormalFloat = { bg = 'None' },
        ColorColumn = { bg = 'None' },
        SignColumn = { bg = 'None' },
        Folded = { bg = 'None' },
        FoldColumn = { bg = 'None' },
        CursorLine = { bg = 'None' },
        CursorColumn = { bg = 'None' },
        VertSplit = { bg = 'None' },
      }, -- Customize specific highlight groups if needed
    }
    vim.cmd 'colorscheme ayu-dark' -- Apply the mirage variant
  end,
}
