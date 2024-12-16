local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'kanagawabones'
config.disable_default_key_bindings = true
config.font_size = 11.0

local act = wezterm.action
config.keys = {
    { key = 'L', mods = 'CTRL',           action = act.ShowDebugOverlay },
    { key = 'C', mods = 'CTRL',           action = act.CopyTo "Clipboard" },
    { key = 'V', mods = 'CTRL',           action = act.PasteFrom "Clipboard" },
    { key = '+', mods = 'CTRL|ALT|SHIFT', action = act.SpawnTab "CurrentPaneDomain" },
    { key = '_', mods = 'CTRL|ALT|SHIFT', action = act.CloseCurrentTab { confirm = true } },
    { key = '{', mods = 'CTRL|ALT|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = '}', mods = 'CTRL|ALT|SHIFT', action = act.ActivateTabRelative(1) },
    { key = '&', mods = 'CTRL|ALT|SHIFT', action = act.ActivateTab(0) },
    { key = '*', mods = 'CTRL|ALT|SHIFT', action = act.ActivateTab(1) },
    { key = '(', mods = 'CTRL|ALT|SHIFT', action = act.ActivateTab(2) },
    { key = ')', mods = 'CTRL|ALT|SHIFT', action = act.ActivateTab(3) },
    {
        key = 'm',
        mods = 'CTRL|ALT|SHIFT',
        action = wezterm.action_callback(function(_, pane)
            pane:move_to_new_window()
        end),
    },
    { key = 'n',        mods = 'CTRL|ALT|SHIFT', action = act.SpawnCommandInNewWindow {} },
    { key = 'PageUp',   mods = 'SHIFT',          action = act.ScrollByPage(-1) },
    { key = 'PageDown', mods = 'SHIFT',          action = act.ScrollByPage(1) },
}

return config
