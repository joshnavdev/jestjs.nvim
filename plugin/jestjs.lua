if vim.g.jestjs_loaded then
  return
end

vim.g.jestjs_loaded = true

local jestjs = require "jestjs"

local api = vim.api
local command = api.nvim_create_user_command

command("JestJS", function ()
  jestjs.test_project()
end, {})

command("JestJSFile", function ()
  jestjs.test_file()
end, {})

command("JestJSSingle", function ()
 jestjs.test_single()
end, {})

-- command("JestJSOpenTestMode", function ()
--   jestjs.open_test_mode()
-- end, {})
--
-- command("JestJSSelectedFile", function ()
--   jestjs.test_selected_file()
-- end, {})

command("JestJSCoverage", function ()
  jestjs.test_coverage()
end, {})
