local M = {}

local utils = require "jestjs.utils"
local jest = require "jestjs.jest"

M.config = {
  test_project_mapping = "<Leader>jp",
  test_file_mapping = "<Leader>jf",
  test_single_mapping = "<Leader>js",
  open_test_mode_mapping = "<Leader>jo",
  test_selected_file_mapping = "<Leader>jmf",
  test_coverage = "<Leader>jc",
}

M.test_project = function()
  local args = {}
  table.insert(args, ' --silent')

  jest.exec_jest(args)
end

M.test_file = function (file_path)
  local current_file = file_path or utils.get_current_file_path()
  local args = {}

  table.insert(args, ' --runTestsByPath ' .. current_file)
  table.insert(args, ' --silent')

  jest.exec_jest(args)
end

M.test_single = function ()
  local current_file = utils.get_current_file_path()
  local test_name = jest.get_test_name()

  if test_name == nil then
    error('Test name not found. Place the cursor on line')
  end

  local args = {}
  table.insert(args, ' --runTestsByPath ' .. current_file)
  table.insert(args, " --testNamePattern='" .. test_name .. "'")

  jest.exec_jest(args)
end

M.test_coverage = function ()
  local args = {}
  table.insert(args, ' --coverage')
  table.insert(args, ' --silent')

  jest.exec_jest(args)
end

M.test_test = function ()
  print('test')
  utils.open_window()
end

M.setup = function (user_opts)
  M.config = vim.tbl_extend("force", M.config, user_opts or {})

  local opts = { silent = true, noremap = true }

  utils.set_keymap(M.config.test_project_mapping, M.test_project, opts)
  utils.set_keymap(M.config.test_file_mapping, M.test_file, opts)
  utils.set_keymap(M.config.test_single_mapping, M.test_single, opts)
  utils.set_keymap(M.config.test_coverage, M.test_coverage, opts)
  utils.set_keymap('<Leader>jtt', M.test_test, opts)
end

return M
