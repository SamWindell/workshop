local ls = require("luasnip")
ls.config.setup()

local this_script_path = debug.getinfo(1, "S").source:sub(2)
local snippets_path = vim.fn.fnamemodify(this_script_path, ":h") .. "/friendly-snippets"

require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })

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
