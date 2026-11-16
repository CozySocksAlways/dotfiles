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
    local content = nil      -- last build_content() result (holds source_line_map)
    local expected = {}      -- win -> line we just moved it to (suppresses sync echo)
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
      content = nil
      expected = {}
    end

    -- Source line -> first rendered line whose source line is >= it.
    local function to_rendered(src_line)
      local map = content and content.source_line_map
      if not map or #map == 0 then return nil end
      for i, sl in ipairs(map) do
        if sl >= src_line then return i end
      end
      return #map
    end

    -- Rendered line -> source line (walk back past unmapped lines, i.e. 0/nil).
    local function to_source(rendered_line)
      local map = content and content.source_line_map
      if not map then return nil end
      for i = math.min(rendered_line, #map), 1, -1 do
        if map[i] and map[i] > 0 then return map[i] end
      end
      return 1
    end

    -- Move `to_win` to `line`, keeping it at the same screen row the cursor
    -- occupies in the (current) `from_win`, so both views scroll together.
    local function sync_to(to_win, line)
      local count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(to_win))
      line = math.max(1, math.min(line, count))
      local row = vim.fn.winline() -- screen row of cursor in the current window
      expected[to_win] = line
      vim.api.nvim_win_set_cursor(to_win, { line, 0 })
      vim.api.nvim_win_call(to_win, function()
        vim.fn.winrestview({ topline = math.max(1, line - row + 1) })
      end)
    end

    -- Returns true if this CursorMoved was caused by our own sync_to().
    local function is_echo(win)
      local exp = expected[win]
      expected[win] = nil
      return exp ~= nil and vim.api.nvim_win_get_cursor(win)[1] == exp
    end

    local function render(source_buf)
      local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
      content = md.preview.build_content(lines, {
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

      vim.wo[split_win].scrollbind = false -- inherited from :vsplit, would fight the sync
      vim.wo[split_win].cursorbind = false

      render(source_buf)

      -- Go back to source
      vim.cmd("wincmd p")
      local source_win = vim.api.nvim_get_current_win()
      vim.wo[source_win].scrollbind = false
      vim.wo[source_win].cursorbind = false

      local function sync_from_source()
        if not (split_win and vim.api.nvim_win_is_valid(split_win)) then return end
        local win = vim.api.nvim_get_current_win()
        if is_echo(win) then return end
        local target = to_rendered(vim.api.nvim_win_get_cursor(win)[1])
        if target then sync_to(split_win, target) end
      end
      sync_from_source()

      -- Source cursor -> preview
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        buffer = source_buf,
        callback = sync_from_source,
      })

      -- Preview cursor -> source (whichever window currently shows the source)
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        buffer = split_buf,
        callback = function()
          if is_echo(split_win) then return end
          local src = to_source(vim.api.nvim_win_get_cursor(split_win)[1])
          local win = vim.fn.bufwinid(source_buf)
          if src and win ~= -1 then sync_to(win, src) end
        end,
      })

      -- Re-render when the source buffer is saved
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        buffer = source_buf,
        callback = function()
          if split_win and vim.api.nvim_win_is_valid(split_win) then
            render(source_buf)
            sync_from_source()
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
