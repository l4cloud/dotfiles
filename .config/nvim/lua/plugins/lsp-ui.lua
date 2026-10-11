-- LSP UI layer.
--
-- Server installation and enabling live in `lua/plugins/lsp.lua` (nvim-lspconfig
-- + Mason). lspsaga only consumes the clients that file sets up and gives them
-- a nicer UI: floating hover, code actions with preview, rename with project
-- search, peeking definitions, diagnostics, outline and call hierarchy.
return {
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      ui = {
        border = 'rounded',
        devicon = vim.g.have_nerd_font,
      },
      -- Lightbulb sign when a code action is available at the cursor
      lightbulb = {
        enable = true,
        sign = true,
        virtual_text = false,
      },
      -- IDE-like breadcrumbs for the current buffer in the winbar
      symbol_in_winbar = {
        enable = true,
        separator = ' › ',
        hide_keyword = true,
        show_file = true,
        folder_level = 1,
      },
      code_action = {
        num_shortcut = true,
        show_server_name = true,
        only_in_cursor = false,
        keys = { quit = 'q', exec = '<CR>' },
      },
      finder = {
        default = 'ref+imp', -- references and implementations
        layout = 'float',
        keys = {
          toggle_or_open = 'o',
          vsplit = 's',
          split = 'i',
          quit = 'q',
          close = '<C-c>k',
        },
      },
      definition = {
        keys = {
          edit = '<C-o>',
          vsplit = '<C-v>',
          split = '<C-x>',
          quit = 'q',
          close = '<ESC>',
        },
      },
      rename = {
        auto_save = false,
        in_select = true,
      },
      outline = {
        auto_preview = true,
        detail = true,
        auto_close = true,
      },
      diagnostic = {
        show_layout = 'float',
        show_normal_height = 10,
        auto_preview = true,
        keys = {
          exec_action = 'o',
          quit = 'q',
          toggle_or_jump = '<CR>',
        },
      },
      beacon = { enable = true },
      scroll_preview = {
        scroll_down = '<C-f>',
        scroll_up = '<C-b>',
      },
    },
    config = function(_, opts)
      require('lspsaga').setup(opts)

      -- Keymaps use the `<leader>g` prefix so they never collide with the
      -- goto/rename/diagnostic keys already set in `plugins/lsp.lua`.
      local map = function(keys, command, desc)
        vim.keymap.set('n', keys, '<cmd>Lspsaga ' .. command .. '<CR>', { desc = 'LSP: ' .. desc })
      end

      -- Navigation and info
      map('<leader>gd', 'peek_definition', 'Peek [D]efinition')
      map('<leader>gD', 'peek_type_definition', 'Peek Type [D]efinition')
      map('<leader>gr', 'finder', '[G]o to [R]eferences / implementations')
      map('<leader>gh', 'hover_doc', 'Hover documentation')
      map('<leader>go', 'outline', 'Symbol [O]utline')

      -- Editing
      map('<leader>gc', 'code_action', '[C]ode action')
      map('<leader>gn', 'rename', 'Re[n]ame (with project search)')

      -- Diagnostics
      map('<leader>gl', 'show_line_diagnostics', 'Show [L]ine diagnostics')
      map('<leader>gb', 'show_buf_diagnostics', 'Show [B]uffer diagnostics')
      map('<leader>gj', 'diagnostic_jump_next', 'Next diagnostic')
      map('<leader>gk', 'diagnostic_jump_prev', 'Previous diagnostic')

      -- Call hierarchy
      map('<leader>gci', 'incoming_calls', '[C]all hierarchy: [I]ncoming')
      map('<leader>gco', 'outgoing_calls', '[C]all hierarchy: [O]utgoing')

      -- Terminal
      map('<leader>gt', 'term_toggle', 'Toggle float [T]erminal')
    end,
  },
}
