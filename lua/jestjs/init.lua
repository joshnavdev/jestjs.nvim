
local Job = require'plenary.job'

local M = {}
local config = {}
local BUFFER_OPTIONS = {
  swapfile = false,
  buftype = "nofile",
  modifiable = false,
  filetype = "NvimTree",
  bufhidden = "wipe",
  buflisted = false,
  -- number = false,
}

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

-- local function get_current_folder_path()
--   return vim.fn.expand('%:p:h')
-- end

local function get_current_file_path()
  return vim.fn.expand('%:p')
end

local function get_local_jest()
  local root_dir = vim.fn.finddir('node_modules/..')
  return root_dir .. '/node_modules/jest/bin/jest.js'
end

local function open_window()
  vim.cmd('botright vnew')
end

local function focus_last_accessed_window()
  vim.cmd('wincmd p')
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

  vim.api.nvim_command(jest_cmd)
end

function M.setup()
  config.jest_cmd = get_local_jest()
end

function M.test_project()
  open_window()
  run_jest()
  focus_last_accessed_window()
end

function M.test_file(file_path)
  local current_file = file_path or get_current_file_path()

  open_window()

  local args = {}
  table.insert(args, ' --runTestsByPath ' .. current_file)
  table.insert(args, ' --silent')

  run_jest(args)

  focus_last_accessed_window()
end

function M.test_single()
  local current_file = get_current_file_path()
  local current_line = vim.api.nvim_get_current_line()
  local _, _, test_name = string.find(current_line, "^%s*%a+%(['\"](.+)['\"]")

  if test_name ~= nil then
    open_window()

    local args = {}
    table.insert(args, ' --runTestsByPath ' .. current_file)
    table.insert(args, ' --testNamePattern=' .. test_name)
    table.insert(args, ' --silent')

    run_jest(args)

    focus_last_accessed_window()
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

return M
