local Job = require'plenary.job'
local keymap = vim.keymap

local M = {}

M.config = {
  test_project_mapping = "<Leader>jp",
  test_file_mapping = "<Leader>jf",
  test_single_mapping = "<Leader>js",
  open_test_mode_mapping = "<Leader>jo",
  test_selected_file_mapping = "<Leader>jmf"
}

local config = {}
local BUFFER_OPTIONS = {
  swapfile = false,
  buftype = "nofile",
  modifiable = false,
  filetype = "NvimTree",
  bufhidden = "wipe",
  buflisted = false,
}

local RIGHT_MATCHES = { "it", "describe", "])", ")" }

local function get_output_command(cmd, args)
  local stdout_results = {}

  local job = Job:new {
    command = cmd,
    args = args,
    on_stdout = function(_, data)
      table.insert(stdout_results, data)
    end,
  }

  job:sync()

  return stdout_results
end

local function get_current_file_path()
  return vim.fn.expand('%:p')
end

local function get_local_jest()
  local root_dir = vim.fn.finddir('node_modules/..')
  return root_dir .. '/node_modules/jest/bin/jest.js'
end

local function open_window()
  local buf, win

  buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
      style = "minimal",
      relative = "editor",
      width = win_width,
      height = win_height,
      row = row,
      col = col,
      border = "rounded",
  }

  win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, "cursorline", true)
end

local function run_jest(args)
  local t = {}

  table.insert(t, 'terminal ' .. config.jest_cmd)

  if args ~= nil then
    for _,v in pairs(args) do
      table.insert(t, v)
    end
  end

  local jest_cmd = table.concat(t, '')

  print(jest_cmd)

  vim.api.nvim_command(jest_cmd)
end

local has_value = function(tab, val)
  for _, tab_val in ipairs(tab) do
    if tab_val == val then
      return true
    end
  end

  return false
end

local get_test_name = function(line)
  local regex = "^%s*(.+)%(['\"](.+)['\"]"

  local first_match, test_name = string.match(line, regex)

  if has_value(RIGHT_MATCHES, first_match) then
    return test_name
  end
end

function M.test_project()
  open_window()

  local args = {}
  table.insert(args, ' --silent')

  run_jest(args)
end

function M.test_file(file_path)
  local current_file = file_path or get_current_file_path()

  open_window()

  local args = {}
  table.insert(args, ' --runTestsByPath ' .. current_file)
  table.insert(args, ' --silent')

  run_jest(args)
end

function M.test_single()
  local current_file = get_current_file_path()
  local current_line = vim.api.nvim_get_current_line()
  local test_name = get_test_name(current_line)

  if test_name ~= nil then
    open_window()

    local args = {}
    table.insert(args, ' --runTestsByPath ' .. current_file)
    table.insert(args, " --testNamePattern='" .. test_name .. "'")
    -- table.insert(args, ' --silent')

    run_jest(args)
  else
    print("Err: test name not found. Place the cursor on line")
  end
end

function M.open_test_mode()
  local jest_cmd = get_local_jest()
  local jest_args = { "--listTests" }
  local lines = get_output_command(jest_cmd, jest_args)

  local new_buf = vim.api.nvim_create_buf(false, false)

  for option, value in pairs(BUFFER_OPTIONS) do
    vim.bo[new_buf][option] = value
  end

  vim.api.nvim_buf_set_option(new_buf, "modifiable", true)
  vim.api.nvim_buf_set_name(new_buf, 'JestJS ' .. new_buf)
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(new_buf, "modifiable", false)
  vim.api.nvim_command('buffer ' .. new_buf)
end

function M.test_selected_file()
  -- TODO: Validar que solo sea en JEST MODE
  local file_path = vim.api.nvim_get_current_line()

  M.test_file(file_path)
end

local set_keymap = function(lhs, callback, opts)
  keymap.set("n", lhs, function ()
    callback()
  end, opts)
end

M.setup = function (user_opts)
  M.config = vim.tbl_extend("force", M.config, user_opts or {})

  config.jest_cmd = get_local_jest()

  local opts = { silent = true, noremap = true }

  set_keymap(M.config.test_project_mapping, M.test_project, opts)
  set_keymap(M.config.test_file_mapping, M.test_file, opts)
  set_keymap(M.config.test_single_mapping, M.test_single, opts)
end

return M
