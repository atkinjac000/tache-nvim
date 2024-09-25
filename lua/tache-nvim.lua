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

local function setup()
    vim.api.nvim_create_user_command('TacheNew', function (opts)
        new_task(opts.fargs[1])
    end, {nargs = 1})

    vim.api.nvim_create_user_command('TacheList', function (opts)
        local tasks = read_tasks()
        for _, task in pairs(tasks) do
            print(task["name"])
        end
    end, {})
end

M.setup = setup

return M
