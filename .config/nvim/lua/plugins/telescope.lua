return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sr', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<c-f>', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>oo', function()
        builtin.find_files(themes.get_ivy {
          find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
          layout_config = {
            height = 0.999,
          },
        })
      end, { desc = '[O]pen [O]veridden files' })

      vim.keymap.set('n', '<leader>o', function()
        builtin.find_files(themes.get_ivy { layout_config = {
          height = 0.999,
        } })
      end, {})

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find()
      end, {})

      vim.keymap.set('n', '<leader><leader>', function()
        builtin.buffers(themes.get_dropdown { width = 0.6, previewer = false })
      end, { desc = 'Search [B]uffers' })

      vim.keymap.set('n', '<leader>p', function()
        builtin.live_grep(themes.get_ivy { layout_config = {
          height = 0.999,
          preview_width = 0.7,
        } })
      end, {})

      vim.keymap.set('n', '<leader>sc', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
