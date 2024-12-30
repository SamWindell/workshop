local ls = require("luasnip")
ls.config.setup()

local this_script_path = debug.getinfo(1, "S").source:sub(2)
local snippets_path = vim.fn.fnamemodify(this_script_path, ":h") .. "/friendly-snippets"

require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })
