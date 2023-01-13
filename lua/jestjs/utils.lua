local M = {}
local keymap = vim.keymap

local BUFFER_OPTIONS = {
  swapfile = false,
  modifiable = false,
  bufhidden = "wipe",
  buflisted = true,
}

local get_windows_opts = function()
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.9)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "double",
  }

  return opts
end

M.open_window = function()
  local buf = vim.api.nvim_create_buf(false, true)
  local opts = get_windows_opts()
  local win = vim.api.nvim_open_win(buf, true, opts)

  vim.api.nvim_win_set_option(win, "cursorline", true)
end

M.set_keymap = function (lhs, callback, opts)
  keymap.set("n", lhs, function() callback() end, opts);
end

M.config_current_buffer = function ()
  local current_buf = vim.api.nvim_get_current_buf()

  for option, value in pairs(BUFFER_OPTIONS) do
    vim.api.nvim_buf_set_option(current_buf, option, value)
  end

  local close_lhs = { "q", "<Esc>" }

  for _, value in ipairs(close_lhs) do
    vim.api.nvim_buf_set_keymap(current_buf, "n", value, ":q<CR>", { silent = true })
  end
end

M.get_current_file_path = function ()
  return vim.fn.expand('%:p')
end

M.get_initial_buf_values = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = M.get_current_file_path()

  return bufnr, file_path
end

M.has_value = function (tab, val)
  for _, tab_val in ipairs(tab) do
    if tab_val == val then
      return true
    end
  end

  return false
end

return M
