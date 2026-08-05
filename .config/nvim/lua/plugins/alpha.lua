return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VimEnter',
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Block letters ASCII art header
    dashboard.section.header.val = {
      [[                                                                     ]],
      [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
      [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
      [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
      [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
      [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
      [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
      [[                                                                     ]],
    }

    -- Menu buttons
    dashboard.section.buttons.val = {
      dashboard.button('f', '  Find file', ':Telescope find_files hidden=true<CR>'),
      dashboard.button('n', '  New file', ':ene <BAR> startinsert<CR>'),
      dashboard.button('r', '  Recent files', ':Telescope oldfiles<CR>'),
      dashboard.button('g', '  Find text', ':Telescope live_grep hidden=true<CR>'),
      dashboard.button('y', '  Yazi', ':Yazi cwd<CR>'),
      dashboard.button('c', '  Configuration', ':e $MYVIMRC<CR>'),
      dashboard.button('l', '󰒲  Lazy', ':Lazy<CR>'),
      dashboard.button('q', '  Quit', ':qa<CR>'),
    }

    -- Footer with lazy stats
    dashboard.section.footer.val = function()
      local stats = require('lazy').stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      return '  ' .. stats.loaded .. '/' .. stats.count .. ' plugins loaded in ' .. ms .. 'ms'
    end

    -- Styling
    dashboard.section.header.opts.hl = 'AlphaHeader'
    dashboard.section.buttons.opts.hl = 'AlphaButtons'
    dashboard.section.footer.opts.hl = 'AlphaFooter'

    -- Layout
    dashboard.config.layout = {
      { type = 'padding', val = 2 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
      { type = 'padding', val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]


  end,
}
