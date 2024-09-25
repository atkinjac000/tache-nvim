local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values

local M = {}

local function read_tasks()
    local tache_file = assert(os.getenv("TACHE_FILE"))
    local f = assert(io.open(tache_file, "r"))
    local tasks = {}
    while true do
        local data = f:read()
        if data == nil then break end
        tasks = vim.json.decode(data)
    end
    f:close()

    return tasks
end

local function new_task(task_name)
    local task_list = read_tasks()

    table.insert(task_list, { name = task_name })
    local data = vim.json.encode(task_list)

    local tache_file = assert(os.getenv("TACHE_FILE"))
    local f = assert(io.open(tache_file, "w+"))
    f:write(data)
    f:flush()
    f:close()
end

local function list_tasks()
    local tasks = read_tasks()
    local task_list = {}
    for _, task in pairs(tasks) do
        table.insert(task_list, task["name"])
    end
    return task_list
end

local tache_picker = function (opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Tache",
        finder = finders.new_table {
            results = list_tasks()
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_put({ selection[1] }, "", false, true)
            end)
            return true
        end,
    }):find()
end

local function setup()
    vim.api.nvim_create_user_command('TacheNew', function (opts)
        new_task(opts.fargs[1])
    end, {nargs = 1})

    vim.api.nvim_create_user_command('TacheList', function (opts)
        list_tasks()
    end, {})

    vim.api.nvim_create_user_command('TachePicker', function (opts)
        tache_picker()
    end, {})
end

M.setup = setup

return M
