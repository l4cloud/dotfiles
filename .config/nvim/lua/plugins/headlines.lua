# headlines.lua configiration that ensures the space between each headding works with a transparent background and code blocks work
return {
{
  "lukas-reineke/headlines.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("headlines").setup {
      markdown = {
        headline_highlights = {
          "Headline1", "Headline2", "Headline3",
          "Headline4", "Headline5", "Headline6"
        },
        codeblock_highlight = "CodeBlock",
        fat_headlines = false,
        bullets = { "◉", "○", "✸", "✿" },
      }
    }
  end,
  ft = { "markdown" },
}


}
