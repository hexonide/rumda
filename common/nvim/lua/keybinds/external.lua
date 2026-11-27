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
