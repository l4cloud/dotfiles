return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    heading = {
      enabled = true,
      sign = false,
      icons = { ' ', '  ', '   ', '    ', '     ', '      ' },
      width = 'full', -- 'full' | 'block'
      left_pad = 0,
      right_pad = 4,
      position = 'inline',
      backgrounds = {
        '',
        '',
        '',
        '',
        '',
        '',
      },
      foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
      },
    },
    code = {
      enabled = true,
      width = 'block',
      border = 'thin',
      language_name = false,
      language_icon = false,
    },
  },
}
