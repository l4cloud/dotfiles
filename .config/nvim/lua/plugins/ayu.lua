return {
  'Shatur/neovim-ayu',
  priority = 1000, -- Make sure to load this before all the other start plugins
  config = function()
    require('ayu').setup {
      mirage = false, -- Set to false to use dark variant instead of mirage
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
    vim.cmd 'colorscheme ayu-dark' -- Apply the dark variant
  end,
}
