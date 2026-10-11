 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#12140d',
    base01 = '#1e2019',
    base02 = '#292b23',
    base03 = '#8f9284',
    base04 = '#c6c8b9',
    base05 = '#e3e3d8',
    base06 = '#e3e3d8',
    base07 = '#e3e3d8',
    base08 = '#ffb4ab',
    base09 = '#a0d0c9',
    base0A = '#c1caab',
    base0B = '#b7d085',
    base0C = '#a0d0c9',
    base0D = '#b7d085',
    base0E = '#c1caab',
    base0F = '#dee6c6',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e3e3d8',          bg = '#12140d' })
  hi('TelescopeBorder',         { fg = '#8f9284',             bg = '#12140d' })
  hi('TelescopePromptNormal',   { fg = '#e3e3d8',          bg = '#12140d' })
  hi('TelescopePromptBorder',   { fg = '#8f9284',             bg = '#12140d' })
  hi('TelescopePromptPrefix',   { fg = '#b7d085',             bg = '#12140d' })
  hi('TelescopePromptCounter',  { fg = '#c6c8b9',  bg = '#12140d' })
  hi('TelescopePromptTitle',    { fg = '#12140d',             bg = '#b7d085' })
  hi('TelescopePreviewTitle',   { fg = '#12140d',             bg = '#c1caab' })
  hi('TelescopeResultsTitle',   { fg = '#12140d',             bg = '#a0d0c9' })
  hi('TelescopeSelection',      { fg = '#e3e3d8',          bg = '#292b23' })
  hi('TelescopeSelectionCaret', { fg = '#b7d085',             bg = '#292b23' })
  hi('TelescopeMatching',       { fg = '#b7d085',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e3e3d8',          bg = '#12140d' })
  hi('MiniPickBorder',         { fg = '#8f9284',             bg = '#12140d' })
  hi('MiniPickPrompt',   { fg = '#e3e3d8',          bg = '#12140d' })
  hi('MiniPickPromptPrefix',   { fg = '#b7d085',             bg = '#12140d' })
  hi('MiniPickBorderText',    { fg = '#12140d',             bg = '#b7d085' })
  hi('MiniPickMatchCurrent',      { fg = '#e3e3d8',          bg = '#292b23' })
  hi('MiniPickPromptCaret', { fg = '#b7d085',             bg = '#292b23' })
  hi('MiniPickMatchRanges',       { fg = '#b7d085',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
