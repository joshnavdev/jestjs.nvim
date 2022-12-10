local M = {}
local BUFNR_PER_TAB = {}
local BUFFER_OPTIONS = {
  swapfile = false,
  buftype = "nofile",
  modifiable = false,
  filetype = "NvimTree",
  bufhidden = "wipe",
  buflisted = false,
  number = false,
}

local function get_dir_handler(cwd)
  local handle = vim.loop.fs_scandir(cwd)
  return handle
end

local function explorer(cwd)
  local handle = get_dir_handler(cwd)

  while true do
    local name, t = vim.loop.fs_scandir_next(handle)

    if not name then
      break
    end

    print(name, t)
  end
end

local function get_bufnr()
  return BUFNR_PER_TAB[vim.api.nvim_get_current_tabpage()]
end

local function create_buffer()
  local tab = vim.api.nvim_get_current_tabpage()
  BUFNR_PER_TAB[tab] = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(get_bufnr(), "JestJSsss ".. tab)

  for option, value in pairs(BUFFER_OPTIONS) do
    vim.bo[get_bufnr()][option] = value
  end
end

local function get_size()
  local size = nil

end

local function reposition_window()
  local move_to = "L"
  vim.api.nvim_command("wincmd " .. move_to)

end

local function open_window()
  vim.api.nvim_command "vsp"
  
end

local function view_open()
  create_buffer()
end

local function open_view_and_draw()
  local cwd = vim.fn.getcwd()

end

local function lib_open()

end

local Job = require'plenary.job'

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

function M.test()
  -- create_buffer()
  -- local cwd = vim.loop.cwd()
  -- cwd = vim.loop.fs_realpath(cwd)
  --
  -- explorer(cwd)
  --
  -- view_open()


  local root_dir = vim.fn.finddir('node_modules/..')
  local jest_cmd = root_dir .. '/node_modules/jest/bin/jest.js'
  local jest_args = { '--listTests' }

  local lines = get_output_command(jest_cmd, jest_args)



  -- local output_command = vim.api.nvim_exec('!ls', true)
  -- print(type(output_command))
  local new_buf = vim.api.nvim_create_buf(false, false)

  for option, value in pairs(BUFFER_OPTIONS) do
    vim.bo[new_buf][option] = value
  end

  vim.api.nvim_buf_set_option(new_buf, "modifiable", true)
  vim.api.nvim_buf_set_name(new_buf, 'JestJS ' .. new_buf)
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(new_buf, "modifiable", false)
  vim.api.nvim_command('buffer ' .. new_buf)

  -- TODO: Crear el window y ponerle sus options
end


return M
