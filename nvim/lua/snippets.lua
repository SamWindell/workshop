local ls = require("luasnip")
ls.config.setup()
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

ls.add_snippets("all", {
    s("ternary", fmt("{} ? {} : {}", {
        i(1, "condition"),
        i(2, "true"),
        i(0, "false")
    })),
})

ls.add_snippets("cpp", {
    s("fn", fmt("{return_type} {name}({args}) {{\n    {body}\n}}", {
        return_type = i(1, "return_type"), name = i(2, "name"), args = i(3, "args"), body = i(0, "body")
    })),
    s("sfn", fmt("static {return_type} {name}({args}) {{\n    {body}\n}}", {
        return_type = i(1, "return_type"), name = i(2, "name"), args = i(3, "args"), body = i(0, "body")
    }))
})
