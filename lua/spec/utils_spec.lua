local mock = require "luassert.mock"

describe("Utils Module", function ()
  local module = require "jestjs.utils"
  local mock_api

  before_each(function ()
    mock_api = mock(vim.api, true)
  end)

  after_each(function ()
    mock.revert(mock_api)
  end)

  describe("has_value method", function ()
    local table_values
    local value

    before_each(function ()
      table_values = { "test1", "test2" }
      value = "test2"
    end)

    it("Should return `true` if the table has the value", function ()
      local res = module.has_value(table_values, value)
      assert.equals(res, true)
    end)

    it("Should return `false` if the table does not have the value", function ()
      value = "test3"
      local res = module.has_value(table_values, value)
      assert.equals(res, false)
    end)
  end)

  describe("config_current_buffer method", function ()
    it("Should config the current_buf", function ()
      mock_api.nvim_get_current_buf.returns(10)

      module.config_current_buffer()

      assert.stub(mock_api.nvim_buf_set_option).was_called(4)
      assert.stub(mock_api.nvim_buf_set_keymap).was_called(2)

      for _, value in ipairs({ "q", "<Esc>" }) do
        assert.stub(mock_api.nvim_buf_set_keymap).was_called_with(10, "n", value, ":q<CR>", { silent = true })
      end
    end)
  end)

  describe("get_current_file_path method", function ()
    it("Should returns the correnct file path", function ()
      local res = module.get_current_file_path()
      assert.equal(res, "")
    end)
  end)

  describe("open_window method", function ()
    it("Should open a window correctly", function ()
      mock_api.nvim_create_buf.on_call_with(false, true).returns(10)
      mock_api.nvim_get_option.on_call_with("columns").returns(236)
      mock_api.nvim_get_option.on_call_with("lines").returns(56)
      mock_api.nvim_open_win.returns(11)

      module.open_window()

      assert.stub(mock_api.nvim_win_set_option).was_called_with(11, 'cursorline', true)
    end)
  end)
end)
