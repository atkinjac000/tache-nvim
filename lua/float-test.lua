local buf = vim.api.nvim_create_buf({false}, {true})
local width = 100
local height = 25 
local tache_win = vim.api.nvim_open_win(buf, true, 
    {
        relative='editor',
        row=1,
        col=vim.api.nvim_win_get_width(0) / 2 - (width / 2),
        width=width,
        height=height,
        focusable=true,
        border='rounded',
        title='tache',
        title_pos='center',

    }
)

vim.api.nvim_buf_set_keymap(buf, 'n', '<esc>', 'vim.api.nvim_win_close(tache_win, true)', {})
