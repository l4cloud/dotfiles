return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    animation = true,
    insert_at_start = true,
    auto_hide = 1,
    icons = {
      buffer_index = true,
    },
  },
  version = '^1.0.0',
  config = function(_, opts)
    require('barbar').setup(opts)

    --- Monkey-patch: replace the local `style_number` in barbar.ui.render
    --- to show buffer indices as hex (1–9 a–f 10 11 ...).
    local render = require('barbar.ui.render')

    local function replace_style_number(fn, depth)
      depth = depth or 0
      if depth > 5 then
        return false
      end
      for i = 1, math.huge do
        local name, val = debug.getupvalue(fn, i)
        if not name then
          break
        end
        if name == 'style_number' then
          debug.setupvalue(fn, i, function(num, style)
            local hex = ('%x'):format(num)
            if style == true then
              return hex, 0
            end
            local digits = style == 'subscript'
              and { '₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉', 'ₐ', 'ₑ', '₂', 'ₓ', 'ₔ', 'ₕ' }
              or { '⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹', 'ᵃ', 'ᵇ', 'ᶜ', 'ᵈ', 'ᵉ', 'ᶠ' }
            return (hex:gsub('.', function(c)
              local n = tonumber(c, 16)
              return n and digits[n + 1] or c
            end))
          end)
          return true
        elseif type(val) == 'function' then
          if replace_style_number(val, depth + 1) then
            return true
          end
        end
      end
      return false
    end

    replace_style_number(render.update)
    render.update()

    -- <leader>1..9 → go to buffer at that index
    local gbuf = require('barbar.api').goto_buffer
    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i, function()
        gbuf(i)
      end, { desc = 'Go to buffer ' .. i })
    end
  end,
}
