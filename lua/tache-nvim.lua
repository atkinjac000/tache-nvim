local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_utils = require "telescope.actions.utils"
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

local function new_task(task_name, priority)
    local task_list = read_tasks()

    table.insert(task_list, { name = task_name, priority = priority, display = task_name })
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
        table.insert(task_list, task["display"])
    end
    return task_list
end

local function complete_task(task_name)
    local task_list = read_tasks()
    for i, task in ipairs(task_list) do
        if task["name"] == task_name then
            table.remove(task_list, i)
        end
    end
    local tache_file = assert(os.getenv("TACHE_FILE"))
    local f = assert(io.open(tache_file, "w+"))
    f:write(vim.json.encode(task_list))
    f:flush()
    f:close()
end

local tache_picker = function (opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Tache",
        finder = finders.new_table {
            results = list_tasks(),
        },
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts),
        attach_mappings = function(prompt_bufnr, map)
            local new_task_from_prompt = function ()
               local current_picker = action_state.get_current_picker(prompt_bufnr)
               local current_line = action_state.get_current_line(prompt_bufnr)
               new_task(current_line)
               current_picker:refresh(finders.new_table{results = list_tasks()}, {reset_prompt = true})
            end
            map({ "i", "n" }, "<c-a>", new_task_from_prompt)

            actions.select_default:replace(function ()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                actions.add_selection(prompt_bufnr)
                action_utils.map_selections(prompt_bufnr, function (entry, index)
                    complete_task(entry.value)
                    current_picker:delete_selection(function (s) if s == entry then return true else return false end end)
                end)
            end)
            return true
        end,
    }):find()
end

local function setup()
    vim.api.nvim_create_user_command('TacheNew', function (opts)
        local priority = opts.fargs[2] or 0
        new_task(opts.fargs[1], priority)
    end, {nargs = "*"})

    vim.api.nvim_create_user_command('TacheList', function (opts)
        list_tasks()
    end, {})

    vim.api.nvim_create_user_command('TachePicker', function (opts)
        tache_picker()
    end, {})
end

M.setup = setup

return M
