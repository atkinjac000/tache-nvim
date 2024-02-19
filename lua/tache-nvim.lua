local augroup = vim.api.nvim_create_augroup("Tache", { clear = true })

local tache_file = assert(os.getenv("TACHE_FILE"))

local function list()
    local task_list = {}
    local f = assert(io.open(tache_file), "r")
    local tasks = {}
    while true do
        local data = f:read()
        if data == nil then break end
        table.insert(tasks, vim.json.decode(data))
    end
    f:close()
    for key, value in pairs(tasks) do
        local complete_string = function () if value.complete then return "complete" else return "incomplete" end end
        table.insert(task_list, key .. " " .. value.name .. " " .. complete_string())
    end
    return task_list
end

local function main()
    vim.api.nvim_create_user_command("List", function () list() end, {})
    local task_list = list()
    table.insert(task_list, 1, "Tache")
    --local tache_buf = vim.api.nvim_create_buf(true, true)
    --vim.api.nvim_set_current_buf(tache_buf)
    --vim.api.nvim_buf_set_lines(tache_buf, 0, -1, false, task_list)
end

local function setup()
    vim.api.nvim_create_autocmd("VimEnter",
        { group = augroup, desc = "Do tache things on load", once = true, callback = main })
end

return { setup = setup }
