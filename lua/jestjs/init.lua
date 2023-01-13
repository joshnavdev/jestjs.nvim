local M = {}

local utils = require "jestjs.utils"
local jest = require "jestjs.jest"
local diagnostic = require "jestjs.diagnostic"

M.config = {
  -- Mapping for running tests of the whole project.
  test_project_mapping = "<Leader>jp",
  -- Mapping for running tests of the current open file.
  test_file_mapping = "<Leader>jf",
  -- Mapping for running tests of the current selected test case.
  test_single_mapping = "<Leader>js",
  open_test_mode_mapping = "<Leader>jo",
  test_selected_file_mapping = "<Leader>jmf",
  -- Mapping for runnign tests and get the coverage results.
  test_coverage = "<Leader>jc",
  -- Run diagnostics after test
  run_diagnostic = true,
}

M.run_diagnostic_if_can = function ()
  if M.config.run_diagnostic then
    local bufnr, file_path = utils.get_initial_buf_values()
    print("Starting diagnostic...")
    diagnostic.start(bufnr, file_path)
  end
end

M.test_project = function()
  local args = {}
  table.insert(args, ' --silent')

  M.run_diagnostic_if_can()
  jest.exec_jest(args)
end

M.test_file = function (file_path)
  local current_file = file_path or utils.get_current_file_path()
  local args = {}

  table.insert(args, ' --runTestsByPath ' .. current_file)
  table.insert(args, ' --silent')

  M.run_diagnostic_if_can()
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

  M.run_diagnostic_if_can()
  jest.exec_jest(args)
end

M.test_coverage = function ()
  local args = {}
  table.insert(args, ' --coverage')
  table.insert(args, ' --silent')

  jest.exec_jest(args)
end

M.setup = function (user_opts)
  M.config = vim.tbl_extend("force", M.config, user_opts or {})

  local opts = { silent = true, noremap = true }

  utils.set_keymap(M.config.test_project_mapping, M.test_project, opts)
  utils.set_keymap(M.config.test_file_mapping, M.test_file, opts)
  utils.set_keymap(M.config.test_single_mapping, M.test_single, opts)
  utils.set_keymap(M.config.test_coverage, M.test_coverage, opts)
end

return M
