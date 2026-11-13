-- Keybinds:

vim.api.nvim_set_keymap("n", "<M-h>", ":vsplit | terminal<CR> | resize 50%<CR>", { noremap = true, silent = true })
-- paste w/o replace
vim.keymap.set("x", "<C-p>", "P", { desc = "Paste over selection without overwriting register" })

-- macro for the double loop
vim.cmd [[
    let @a = 'i  for (int i = 0; i < 10; i++) {for (int k = 0; k < 10; k++) {}}'
]]
vim.api.nvim_set_keymap("n", "<leader>l", "@a", { noremap = true, silent = true })
-- Markdown formatting keymaps (accessed via <Leader>w)
vim.keymap.set("v", "<Leader>wb", 'c**<C-r>"**<Esc>', { desc = "Bold selection" })
vim.keymap.set("v", "<Leader>wi", 'c*<C-r>"*<Esc>', { desc = "Italic selection" })
vim.keymap.set("v", "<Leader>wu", 'c_<C-r>"_<Esc>', { desc = "Underline/emphasis selection" })
vim.keymap.set("v", "<Leader>wl", 'c[<C-r>"]()<Esc>i', { desc = "Create link (add URL)" })
vim.keymap.set("v", "<Leader>ws", 'c~<C-r>"~<Esc>', { desc = "Strikethrough" })

-- Text wrappers (accessed via <Leader>w)
vim.keymap.set("v", "<Leader>w[", 'c_[<C-r>"]_<Esc>', { desc = "Wrap in _[text]_" })
vim.keymap.set("v", "<Leader>w(", 'c(<C-r>")<Esc>', { desc = "Wrap in (text)" })
vim.keymap.set("v", "<Leader>w{", 'c{<C-r>"}<Esc>', { desc = "Wrap in {text}" })
vim.keymap.set("v", "<Leader>w]", 'c[<C-r>"]<Esc>', { desc = "Wrap in [text]" })
vim.keymap.set("v", '<Leader>w"', 'c"<C-r>""<Esc>', { desc = 'Wrap in "text"' })
vim.keymap.set("v", "<Leader>w'", "c'<C-r>\"'<Esc>", { desc = "Wrap in 'text'" })
vim.keymap.set("v", "<Leader>w<", 'c<<C-r>"><Esc>', { desc = "Wrap in <text>" })
vim.keymap.set("v", "<Leader>w`", 'c`<C-r>"`<Esc>', { desc = "Wrap in `text`" })
-- unwrap strikethrough
vim.keymap.set("x", "<Leader>wS", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local stripped = line:gsub("~~(.-)~~", "%1")
    if stripped ~= line then
      vim.fn.setline(lnum, stripped)
    end
  end
end, { desc = "Remove strikethrough from selected lines" })

-- Code block
vim.keymap.set("n", "<Leader>wcb", "i```<CR>```<Esc>O", { desc = "Code block" })

-- Subscript and superscript
vim.keymap.set("v", "<Leader>wd", 'c<sub><C-r>"</sub><Esc>', { desc = "Subscript (wrap in <sub>)" })
vim.keymap.set("v", "<Leader>wD", 'c<sup><C-r>"</sup><Esc>', { desc = "Superscript (wrap in <sup>)" })

-- Collapsible details block (selection becomes hidden)
vim.keymap.set(
  "v",
  "<Leader>wx",
  'c<details><CR><summary>collapsible</summary><CR><C-r>"<CR></details><Esc>',
  { desc = "Wrap in <details> (selection is collapsed)" }
)

-- markdown list reference construction / searching
local function list_item_text(lnum)
  local line = vim.fn.getline(lnum)
  return line:match "^%s*[%*%-%+]%s+(.-)%s*$" or line:match "^%s*%d+[.)]%s+(.-)%s*$"
end

local function buf_indent(buf, line)
  local ws = line:match "^%s*"
  local width = 0
  local tab = vim.bo[buf].tabstop
  for ch in ws:gmatch "." do
    if ch == "\t" then
      width = width + tab - (width % tab)
    else
      width = width + 1
    end
  end
  return width
end

local function item_of_line(line)
  return line:match "^%s*[%*%-%+]%s+(.-)%s*$" or line:match "^%s*%d+[.)]%s+(.-)%s*$"
end

local function scope_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local init = 1
  while true do
    local s, e = line:find("[%w_%-]+::[%w_%-:]*[%w_%-]", init)
    if not s then
      return nil
    end
    local tail_end = e
    if line:sub(e + 1, e + 1):match "%s" and item_of_line(line) then
      tail_end = #line:gsub("%s+$", "")
    end
    if col >= s and col <= tail_end then
      local segments = {}
      local starts = {}
      local chosen
      local pos = s
      for seg in line:sub(s, e):gmatch "[^:]+" do
        table.insert(segments, seg)
        table.insert(starts, pos)
        if not chosen and col <= pos + #seg + 1 then
          chosen = #segments
        end
        pos = pos + #seg + 2
      end
      chosen = chosen or #segments
      local candidates = {}
      if chosen == #segments then
        local words = vim.split(vim.trim(line:sub(starts[#starts])), "%s+")
        for n = #words, 1, -1 do
          table.insert(candidates, table.concat(words, " ", 1, n))
        end
      end
      local trimmed = {}
      for k = 1, chosen do
        trimmed[k] = segments[k]
      end
      return trimmed, chosen == #segments, candidates
    end
    init = e + 1
  end
end

local function find_scope(buf, segments, prefix_last)
  local stack = {}
  local fenced = false
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for lnum, line in ipairs(lines) do
    if line:match "^%s*```" or line:match "^%s*~~~" then
      fenced = not fenced
    elseif not fenced then
      local text = item_of_line(line)
      if text then
        local indent = buf_indent(buf, line)
        while #stack > 0 and stack[#stack].indent >= indent do
          table.remove(stack)
        end
        table.insert(stack, { indent = indent, text = (text:gsub("%s+", "_")), raw = text })
        if #stack >= #segments then
          local ok = true
          for k = 1, #segments do
            local entry = stack[#stack - #segments + k]
            local want = segments[k]
            if k == #segments then
              if prefix_last then
                ok = entry.raw:sub(1, #want) == want
              else
                ok = entry.raw == want
              end
            else
              ok = entry.text == want
            end
            if not ok then
              break
            end
          end
          if ok then
            return lnum
          end
        end
      end
    end
  end
end

local function search_buffers(segments, prefix_last)
  local current = vim.api.nvim_get_current_buf()
  local order = { current }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      table.insert(order, buf)
    end
  end
  for _, buf in ipairs(order) do
    local lnum = find_scope(buf, segments, prefix_last)
    if lnum then
      return buf, lnum
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "gd", function()
      local segments, is_last, candidates = scope_at_cursor()
      if not segments then
        vim.cmd "normal! gd"
        return
      end
      local buf, lnum
      if is_last then
        local probe = vim.deepcopy(segments)
        for _, cand in ipairs(candidates) do
          probe[#probe] = cand
          buf, lnum = search_buffers(probe, false)
          if buf then
            break
          end
        end
        if not buf then
          probe[#probe] = candidates[#candidates]
          buf, lnum = search_buffers(probe, true)
        end
      else
        buf, lnum = search_buffers(segments, false)
      end
      if not buf then
        vim.notify("Scope not found: " .. table.concat(segments, "::"), vim.log.levels.WARN)
        return
      end
      vim.cmd "normal! m'"
      if buf ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_set_current_buf(buf)
      end
      local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
      vim.api.nvim_win_set_cursor(0, { lnum, line:find "%S" - 1 })
      vim.cmd "normal! zvzz"
    end, { buffer = args.buf, desc = "Jump to list item for scope" })
  end,
})

-- copy list item as a construct 
vim.keymap.set("n", "yc", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local current = list_item_text(row)
  if not current then
    return
  end
  local parts = {}
  local level = vim.fn.indent(row)
  for lnum = row - 1, 1, -1 do
    if level == 0 then
      break
    end
    local text = list_item_text(lnum)
    if text then
      local indent = vim.fn.indent(lnum)
      if indent < level then
        table.insert(parts, 1, (text:gsub("%s+", "_")))
        level = indent
      end
    end
  end
  table.insert(parts, current)
  local result = table.concat(parts, "::")
  vim.fn.setreg('"', result)
  vim.fn.setreg("+", result)
  vim.notify(result)
end, { desc = "Copy list item path" })


-- CURSOR AND SCROLLING STUFF
vim.keymap.set("n", "<leader>tn", ":set relativenumber!<CR>", { desc = "Toggle relative numbers on lines" })

-- git hunks
vim.keymap.set("n", "]h", function()
  require("gitsigns").next_hunk()
end, { desc = "Next Git hunk" })
vim.keymap.set("n", "[h", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous Git hunk" })

-- insert underscore on <count> char
local function insert_underscore(direction)
  local count = vim.v.count1
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local len = #vim.api.nvim_get_current_line()
  local at, cursor

  if direction > 0 then
    at = math.min(col + count, len)
    cursor = math.min(at + 1, len)
  else
    at = math.max(col - count + 1, 0)
    cursor = math.max(at - 1, 0)
  end

  vim.api.nvim_buf_set_text(0, row - 1, at, row - 1, at, { "_" })
  vim.api.nvim_win_set_cursor(0, { row, cursor })
end

vim.keymap.set("n", "]u", function()
  insert_underscore(1)
end, { desc = "Insert underscore N chars right" })

vim.keymap.set("n", "[u", function()
  insert_underscore(-1)
end, { desc = "Insert underscore N chars left" })

-- inline comment padding control
vim.keymap.set("n", "gy", function()
  local target = vim.v.count > 0 and vim.v.count or 65
  local line = vim.api.nvim_get_current_line()
  local pad = target - 1 - vim.fn.strdisplaywidth(line)
  if pad > 0 then
    vim.api.nvim_set_current_line(line .. string.rep(" ", pad))
  end
  vim.cmd "startinsert!"
end, { desc = "Pad line to column and insert" })

local function comment_start(row, line)
  local trimmed = line:gsub("%s+$", "")
  if trimmed == "" then
    return nil
  end
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = 0, pos = { row, #trimmed - 1 } })
  if ok and node then
    while node:parent() and node:parent():type():match "comment" do
      node = node:parent()
    end
    if node:type():match "comment" then
      local srow, scol = node:range()
      if srow == row then
        return scol
      end
    end
    return nil
  end
  local leader = vim.bo.commentstring:match "^(.-)%s*%%s"
  if leader and leader ~= "" then
    local idx = line:find(leader, 1, true)
    return idx and idx - 1
  end
end

vim.keymap.set("x", "gy", function()
  local target = vim.v.count > 0 and vim.v.count or 65
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local start = comment_start(lnum - 1, line)
    if start then
      local code = line:sub(1, start):gsub("%s+$", "")
      local pad = target - 1 - vim.fn.strdisplaywidth(code)
      if code == "" or pad >= 1 then
        vim.fn.setline(lnum, code .. string.rep(" ", math.max(pad, 0)) .. line:sub(start + 1))
      end
    end
  end
  vim.cmd "normal! \27"
end, { desc = "Align inline comments to column" })

-- Error toggling
local diagnostic_modes = {
  { name = "errors only", min = vim.diagnostic.severity.ERROR },
  { name = "errors and warnings", min = vim.diagnostic.severity.WARN },
  { name = "everything", min = vim.diagnostic.severity.HINT },
  { name = "hidden", min = nil },
}

local diagnostic_index = 1

local function apply_diagnostic_mode()
  local mode = diagnostic_modes[diagnostic_index]
  if mode.min == nil then
    vim.diagnostic.config {
      virtual_text = false,
      signs = false,
      underline = false,
    }
    return
  end
  local filter = { severity = { min = mode.min } }
  vim.diagnostic.config {
    severity_sort = true,
    signs = filter,
    virtual_text = filter,
    underline = filter,
    float = filter,
  }
end

vim.schedule(apply_diagnostic_mode)
vim.api.nvim_create_autocmd("LspAttach", { callback = apply_diagnostic_mode })

vim.keymap.set("n", "<Leader>td", function()
  diagnostic_index = diagnostic_index % #diagnostic_modes + 1
  apply_diagnostic_mode()
  vim.notify("Diagnostics: " .. diagnostic_modes[diagnostic_index].name)
end, { desc = "Cycle diagnostic visibility" })

-- select inline comment
vim.keymap.set("x", "gs", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  local spans = {}
  local top, bottom
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local start = comment_start(lnum - 1, line)
    if start then
      local code = line:sub(1, start):gsub("%s+$", "")
      spans[lnum] = { code = code, comment = line:sub(start + 1) }
      top = top or lnum
      bottom = lnum
    end
  end
  if not top then
    return
  end
  local width = 0
  for lnum = top, bottom do
    local text = spans[lnum] and spans[lnum].code or vim.fn.getline(lnum)
    width = math.max(width, vim.fn.strdisplaywidth(text))
  end
  for lnum, span in pairs(spans) do
    local pad = width + 1 - vim.fn.strdisplaywidth(span.code)
    vim.fn.setline(lnum, span.code .. string.rep(" ", pad) .. span.comment)
  end
  vim.api.nvim_win_set_cursor(0, { top, 0 })
  vim.cmd("normal! " .. (width + 2) .. "|")
  vim.cmd "normal! \22"
  vim.cmd("normal! " .. (bottom - top) .. "j")
  vim.cmd "normal! $"
end, { desc = "Select inline comments of selected lines" })


-- whitespace del
vim.keymap.set("n", "<Leader>tw", function()
  local id = vim.fn.matchadd("Search", [[\s\+$]], 100)
  vim.cmd "redraw"
  local choice = vim.fn.confirm("Delete highlighted trailing whitespace?", "&Yes\n&No", 2)
  vim.fn.matchdelete(id)
  if choice == 1 then
    local view = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(view)
  end
end, { desc = "Preview and trim trailing whitespace" })

-- play vid
vim.keymap.set("n", "<Leader>gv", function()
  local target = vim.fn.expand "<cfile>"
  vim.cmd("vsplit | terminal mpv --vo=tct --loop " .. vim.fn.shellescape(target))
end, { desc = "Play file under cursor in mpv" })

-- file manager open
vim.keymap.set("n", "gZ", function()
  local file = vim.fn.expand "%:p"
  vim.fn.jobstart({
    "dbus-send",
    "--session",
    "--print-reply",
    "--dest=org.freedesktop.FileManager1",
    "/org/freedesktop/FileManager1",
    "org.freedesktop.FileManager1.ShowItems",
    "array:string:file://" .. file,
    "string:",
  }, { detach = true })
end, { desc = "Reveal current file in file manager" })

vim.keymap.set("n", "gz", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local target
  local init = 1
  while true do
    local s, e, path = line:find("%[[^%]]*%]%(([^)]+)%)", init)
    if not s then
      break
    end
    if col >= s and col <= e then
      target = path
      break
    end
    init = e + 1
  end
  target = target or vim.fn.expand "<cfile>"
  if target == "" then
    return
  end
  target = (target:gsub("^~", vim.env.HOME))
  if not target:match "^/" then
    target = vim.fn.expand "%:p:h" .. "/" .. target
  end
  target = vim.fn.fnamemodify(target, ":p")
  local dir = vim.fn.isdirectory(target) == 1 and target or vim.fn.fnamemodify(target, ":h")
  vim.fn.jobstart({
    "dbus-send",
    "--session",
    "--print-reply",
    "--dest=org.freedesktop.FileManager1",
    "/org/freedesktop/FileManager1",
    "org.freedesktop.FileManager1.ShowItems",
    "array:string:" .. vim.uri_from_fname(target),
    "string:",
  }, {
    detach = true,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.fn.jobstart({ "xdg-open", dir }, { detach = true })
      end
    end,
  })
end, { desc = "Reveal link under cursor in file manager" })
