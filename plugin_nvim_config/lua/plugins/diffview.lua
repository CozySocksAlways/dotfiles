return {
  "sindrets/diffview.nvim",
  config = function()
    require("diffview").setup({
      view = {
        file_history = {
          win_config = function()
            return {
              type = "split",
              position = "bottom",
              height = 14,
              relative = "win",
              win = vim.api.nvim_tabpage_list_wins(0)[1],
            }
          end,
        },
      },

      log_options = {
        single_file = {
          -- equivalent to: git log --pretty=oneline
          pretty = "oneline",
        },
        multi_file = {
          pretty = "oneline",
        },
      },
    })
  end,
}

