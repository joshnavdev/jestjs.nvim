local jest = require "jestjs.jest"
local diagnostic = {}

local clear_empty_table = function(data)
  local temp = {}

  for _, line in ipairs(data) do
    if line  ~= "" then
      table.insert(temp, line)
    end
  end

  return temp
end

diagnostic.analyze_buffer_content = function ()
  local content = vim.api.nvim_buf_get_lines(diagnostic.bufnr, 0, -1, false)

  for idx, line in ipairs(content) do
    local test_name = jest.get_test_name_from_line(line)

    if test_name ~= nil then
      local test_data = { test_name = test_name, lin = idx - 1, }
      table.insert(diagnostic.file_state.all_tests, test_data)
    end
  end
end

diagnostic.get_message_error = function (assertion)
  local failureResult = assertion.failureDetails[1]
  local hasMatcherResult = failureResult.matcherResult == nil
  local message = hasMatcherResult and failureResult.message or failureResult.matcherResult.message

  return "Test Failed.\n"..message
end

diagnostic.update_file_state = function (assertion)
  for _, test in ipairs(diagnostic.file_state.all_tests) do
    if test.test_name == assertion.title then
      if assertion.status == "passed" then
        local test_diag = vim.tbl_extend("force", test, { status = "passed" })
        table.insert(diagnostic.file_state.passed_tests, test_diag)
      elseif assertion.status == "failed" then
        local new_test_info = { status = "failed", message = diagnostic.get_message_error(assertion) }
        local test_diag = vim.tbl_extend("force", test, new_test_info)
        table.insert(diagnostic.file_state.failed_tests, test_diag)
      end
    end
  end
end

diagnostic.match_jest_result_with_content = function (jest_result)
  local test_results = jest_result["testResults"]
  for _, result in ipairs(test_results) do
    if result["name"] == diagnostic.file_path then
      local assertions = result["assertionResults"]

      for _, assertion in ipairs(assertions) do
        diagnostic.update_file_state(assertion)
      end
    end
  end
end

diagnostic.update_namespace_passes_tests = function ()
  for _, passed_test in ipairs(diagnostic.file_state.passed_tests) do
    local text = { " ✔ ", "DiagnosticVirtualTextInfo" }
    local lin = tonumber(passed_test.lin)
    local opts = { virt_text = { text }, id = lin }

    vim.api.nvim_buf_set_extmark(diagnostic.bufnr, diagnostic.ns, lin, 0, opts)
  end
end

diagnostic.update_namespace_failed_tests = function ()
  local current_diagnostics = {}

  for _, failed_test in ipairs(diagnostic.file_state.failed_tests) do
    local current_diag = {
      lnum = tonumber(failed_test.lin),
      col = 1,
      message = failed_test.message,
      severity = vim.diagnostic.severity.ERROR,
      source = "JestJS"
    }

    table.insert(current_diagnostics, current_diag)
  end

  vim.diagnostic.set(diagnostic.ns, diagnostic.bufnr, current_diagnostics, {})
end

diagnostic.start_jest_diagnostic = function ()
  local state = {}
  vim.api.nvim_buf_clear_namespace(diagnostic.bufnr, diagnostic.ns, 0, -1)

  local append_data = function (_, data)
    if not data then
      return
    end

    local clean_data = clear_empty_table(data)

    if #clean_data ~= 0 then
     table.insert(state, clean_data)
    end
  end

  vim.fn.jobstart(diagnostic.command, {
    stdout_buffered = true,
    on_stdout = append_data,
    on_stderr = append_data,
    on_exit = function ()
      local jest_result_string = state[#state][1]
      local jest_result = vim.json.decode(jest_result_string)
      diagnostic.match_jest_result_with_content(jest_result)
      diagnostic.update_namespace_passes_tests()
      diagnostic.update_namespace_failed_tests()
    end
  })
end

diagnostic.pre_start = function (bufnr, file_path)
  diagnostic.bufnr = bufnr
  diagnostic.file_path = file_path
  diagnostic.ns = vim.api.nvim_create_namespace("JestJSNamespace")

  diagnostic.command = { "jest", "--json", "--watchAll=false", "--runTestsByPath="..diagnostic.file_path }

  diagnostic.file_state = {
    all_tests = {},
    passed_tests = {},
    failed_tests = {},
  }
end

diagnostic.start = function (bufnr, file_path)
  diagnostic.pre_start(bufnr, file_path)
  diagnostic.analyze_buffer_content()
  diagnostic.start_jest_diagnostic()
end

-- -- test
-- local bufnr = 35
-- local file_path = "/Users/joshua.navarro/workplace/projects/nvim/example.spec.js"
--
-- diagnostic.start(bufnr, file_path)

return diagnostic
