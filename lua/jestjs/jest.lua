local utils = require "jestjs.utils"
local M = {}

local RIGHT_MATCHES = { "it", "describe", "])", ")" }

local get_local_jest = function()
  -- TODO: Validate if this local jest exists
  local root_dir = vim.fn.finddir('node_modules/..')
  return root_dir .. '/node_modules/jest/bin/jest.js'
end

M.run_jest = function(args)
  local t = {}
  local jest_cmd = get_local_jest()

  table.insert(t, 'terminal ' .. jest_cmd)

  if args ~= nil then
    for _,v in pairs(args) do
      table.insert(t, v)
    end
  end

  jest_cmd = table.concat(t, '')

  vim.api.nvim_command(jest_cmd)
end

M.get_test_name = function ()
  local regex = "^%s*(.+)%(['\"](.+)['\"]"
  local line = vim.api.nvim_get_current_line()

  local first_match, test_name = string.match(line, regex)

  if utils.has_value(RIGHT_MATCHES, first_match) then
    return test_name
  end
end

M.exec_jest = function (args)
  utils.open_window()
  M.run_jest(args)
  utils.config_current_buffer()
end

return M
