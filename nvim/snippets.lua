local ls = require("luasnip")
ls.config.setup()

local current_path = vim.fn.expand("%:p:h")
require("luasnip.loaders.from_vscode").lazy_load({ paths = { current_path .. "/nvim/friendly-snippets" } })

vim.keymap.set({ 'i', 's' }, '<c-l>', function()
    local luasnip = require('luasnip')
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    end
end, { desc = 'Goto next node in snippet', silent = true })

vim.keymap.set({ 'i', 's' }, '<c-h>', function()
    local luasnip = require('luasnip')
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
    end
end, { desc = 'Goto previous node in snippet', silent = true })
