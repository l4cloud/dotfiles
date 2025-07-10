return {
  'Shatur/neovim-ayu',
  config = function()
    require('ayu').setup {
      mirage = true, -- Use the mirage variant
      terminal = true, -- Let the theme manage terminal colors
      overrides = {}, -- Customize specific highlight groups if needed
    }
    vim.cmd 'colorscheme ayu-dark' -- Apply the mirage variant
  end,
}
