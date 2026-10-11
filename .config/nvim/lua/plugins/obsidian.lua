return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- use latest release, remove to use latest commit
  -- obsidian.nvim errors during setup when no valid workspace exists, which
  -- breaks startup on machines without the vault. Only load it when ~/Notes is
  -- actually present.
  cond = function()
    return vim.fn.isdirectory(vim.fn.expand '~/Notes') == 1
  end,
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    workspaces = {
      {
        name = 'Notes',
        path = '~/Notes',
      },
    },
    picker = {
      name = 'telescope.nvim',
      note_mappings = {
        new = '<S-CR>',
      },
    },
  },
}
