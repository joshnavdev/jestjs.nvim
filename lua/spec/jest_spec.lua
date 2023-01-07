local mock = require "luassert.mock"

describe("Jest Module", function ()
  local module = require "jestjs.jest"
  local mock_api

  before_each(function ()
    mock_api = mock(vim.api, true)
  end)

  after_each(function ()
    mock.revert(mock_api)
  end)

  describe("get_test_name method", function ()
    local right_matches = { "it", "describe", "])", ")" }

    for _, right_match in ipairs(right_matches) do
      it("Should get the the name correctly when starts with " .. right_match, function ()
        mock_api.nvim_get_current_line.returns(right_match .. "('Should be a test name')")
        local response = module.get_test_name()

        assert.equals(response, "Should be a test name")
      end)
    end

    it("Should be nil if there no test name", function ()
      mock_api.nvim_get_current_line.returns("print('Not a test name')")
      local response = module.get_test_name()

      assert.is_nil(response)
    end)
  end)

  describe("run_jest method", function ()
    it ("Should run a corret nvim_command", function ()
      local root_dir = '/node_modules/jest/bin/jest.js'
      module.run_jest({" --silent"})

      assert.stub(mock_api.nvim_command).was_called_with("terminal " .. root_dir .. " --silent")
    end)
end)

  describe("exec_jest method", function ()
    it("Should call the correct methods", function ()
      mock_api.nvim_create_buf.on_call_with(false, true).returns(10)
      mock_api.nvim_get_option.on_call_with("columns").returns(236)
      mock_api.nvim_get_option.on_call_with("lines").returns(56)
      mock_api.nvim_get_current_buf.returns(10)
      module.exec_jest({})

      assert.stub(mock_api.nvim_create_buf).was_called(1)
      assert.stub(mock_api.nvim_get_option).was_called(2)
      assert.stub(mock_api.nvim_open_win).was_called(1)
      assert.stub(mock_api.nvim_win_set_option).was_called(1)
      assert.stub(mock_api.nvim_buf_set_option).was_called(4)
      assert.stub(mock_api.nvim_buf_set_keymap).was_called(2)
    end)
end)
end)
