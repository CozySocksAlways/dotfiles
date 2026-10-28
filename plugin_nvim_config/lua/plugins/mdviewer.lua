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
    local md = require("md-render")

    -- Render tables (and code blocks) expanded by default, i.e. wrap cell text instead
    -- of truncating with "…". The plugin's previews always pass in a fresh expand_state
    -- table, so default its missing entries to true; <CR>/click still collapses a block.
    local build_content = md.preview.build_content
    md.preview.build_content = function(lines, opts)
      opts = opts or {}
      opts.expand_state = opts.expand_state or {}
      if getmetatable(opts.expand_state) == nil then
        setmetatable(opts.expand_state, { __index = function() return true end })
      end
      return build_content(lines, opts)
    end

    -- Vertical split preview using the library API
    local split_buf = nil
    local split_win = nil
    local image_state = nil
    local augroup = vim.api.nvim_create_augroup("md_render_vsplit", { clear = true })
    local ns = vim.api.nvim_create_namespace("md_render_vsplit")

    local function close_split()
      vim.api.nvim_clear_autocmds({ group = augroup })
      if split_win and vim.api.nvim_win_is_valid(split_win) then
        vim.api.nvim_win_close(split_win, true)
      end
      split_win = nil
      split_buf = nil
      image_state = nil
    end

    local function render(source_buf)
      local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
      local content = md.preview.build_content(lines, {
        max_width = vim.api.nvim_win_get_width(split_win) - 2,
        buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(source_buf), ":h"),
      })

      vim.bo[split_buf].modifiable = true
      vim.api.nvim_buf_clear_namespace(split_buf, ns, 0, -1)
      md.display_utils.apply_content_to_buffer(split_buf, ns, content)
      vim.bo[split_buf].modifiable = false

      if image_state then
        image_state = md.display_utils.update_images(image_state, split_win, content)
      else
        image_state = md.display_utils.setup_images(split_win, content, ns)
      end
    end

    vim.keymap.set("n", "<leader>ms", function()
      -- Close if already open
      if split_win and vim.api.nvim_win_is_valid(split_win) then
        close_split()
        return
      end

      local source_buf = vim.api.nvim_get_current_buf()

      -- Create split
      vim.cmd("vsplit")
      split_win = vim.api.nvim_get_current_win()
      split_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(split_win, split_buf)

      -- Make it read-only and clean
      vim.bo[split_buf].buftype = "nofile"
      vim.wo[split_win].wrap = false
      vim.wo[split_win].number = false
      vim.wo[split_win].signcolumn = "no"

      render(source_buf)

      -- Go back to source
      vim.cmd("wincmd p")

      -- Re-render when the source buffer is saved
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        buffer = source_buf,
        callback = function()
          if split_win and vim.api.nvim_win_is_valid(split_win) then
            render(source_buf)
          end
        end,
      })

      -- Auto-close when source buffer is closed
      vim.api.nvim_create_autocmd("BufWipeout", {
        group = augroup,
        buffer = source_buf,
        once = true,
        callback = close_split,
      })

      -- Clean up if the split is closed some other way (e.g. :q)
      vim.api.nvim_create_autocmd("WinClosed", {
        group = augroup,
        pattern = tostring(split_win),
        once = true,
        callback = close_split,
      })
    end, { desc = "Markdown preview (vsplit toggle)" })
  end,
}
