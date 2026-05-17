return {
  "delphinus/md-render.nvim",
  version = "*",
  keys = {
    { "<leader>mp", "<Plug>(md-render-preview)",     desc = "Markdown preview (toggle)" },
    { "<leader>mt", "<Plug>(md-render-preview-tab)", desc = "Markdown preview in tab (toggle)" },
    { "<leader>md", "<Plug>(md-render-demo)",        desc = "Markdown render demo" },
    { "<leader>ms", desc = "Markdown preview (vsplit)" }, -- AI generated stuff, the above keys is okay and from the plugin docs
  },
  -- So this is from claude and might break on update,
  config = function()
    -- Vertical split preview using the library API
    local split_buf = nil
    local split_win = nil

    vim.keymap.set("n", "<leader>ms", function()
      -- Close if already open
      if split_win and vim.api.nvim_win_is_valid(split_win) then
        vim.api.nvim_win_close(split_win, true)
        split_win = nil
        split_buf = nil
        return
      end

      local md = require("md-render")
      local source_buf = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)

      -- Create split
      vim.cmd("vsplit")
      split_win = vim.api.nvim_get_current_win()
      split_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(split_win, split_buf)

      -- Render
      local ns = vim.api.nvim_create_namespace("md_render_vsplit")
      local width = vim.api.nvim_win_get_width(split_win)

      local b = md.ContentBuilder.new()
      b:render_document(lines, { max_width = width - 2 })
      local content = b:result()

      md.display_utils.apply_content_to_buffer(split_buf, ns, content)
      md.display_utils.setup_images(split_win, content, ns)

      -- Make it read-only and clean
      vim.bo[split_buf].modifiable = false
      vim.bo[split_buf].buftype = "nofile"
      vim.wo[split_win].wrap = false
      vim.wo[split_win].number = false
      vim.wo[split_win].signcolumn = "no"

      -- Go back to source
      vim.cmd("wincmd p")

      -- Auto-close when source buffer is closed
      vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = source_buf,
        once = true,
        callback = function()
          if split_win and vim.api.nvim_win_is_valid(split_win) then
            vim.api.nvim_win_close(split_win, true)
          end
        end,
      })
    end, { desc = "Markdown preview (vsplit toggle)" })
  end,
}
