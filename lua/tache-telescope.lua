local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values

local tache_picker = function (opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "colors",
        finder = finders.new_table {
            results = {"red", "green", "blue"}
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
