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

    -- Revert to start screen when closing last buffer
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BDeletePost*',
      callback = function(event)
        local fallback_name = vim.api.nvim_buf_get_name(event.buf)
        local fallback_ft = vim.api.nvim_get_option_value('filetype', { buf = event.buf })
        local fallback_on_empty = fallback_name == '' and fallback_ft == ''

        if fallback_on_empty then
          vim.cmd 'Alpha'
          vim.cmd(event.buf .. 'bwipeout')
        end
      end,
    })

    -- Also handle regular buffer delete
    vim.api.nvim_create_autocmd('BufDelete', {
      callback = function()
        local bufs = vim.tbl_filter(function(b)
          return vim.api.nvim_buf_is_valid(b)
            and vim.api.nvim_buf_get_option(b, 'buflisted')
            and vim.api.nvim_buf_get_name(b) ~= ''
        end, vim.api.nvim_list_bufs())

        if #bufs == 0 then
          vim.defer_fn(function()
            local current_buf = vim.api.nvim_get_current_buf()
            local current_name = vim.api.nvim_buf_get_name(current_buf)
            local current_ft = vim.api.nvim_get_option_value('filetype', { buf = current_buf })
            if current_name == '' and current_ft ~= 'alpha' then
              vim.cmd 'Alpha'
            end
          end, 10)
        end
      end,
    })

    -- Override :q to show Alpha instead of quitting when it's the last buffer
    vim.api.nvim_create_user_command('Q', function()
      local bufs = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_valid(b)
          and vim.api.nvim_get_option_value('buflisted', { buf = b })
          and vim.api.nvim_buf_get_name(b) ~= ''
      end, vim.api.nvim_list_bufs())

      local current_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

      if #bufs <= 1 and current_ft ~= 'alpha' then
        vim.cmd 'bdelete'
        vim.cmd 'Alpha'
      else
        vim.cmd 'quit'
      end
    end, {})

    -- Remap :q to use our custom Q command
    vim.cmd [[cabbrev q <c-r>=getcmdtype() == ':' && getcmdpos() == 1 ? 'Q' : 'q'<CR>]]
  end,
}
