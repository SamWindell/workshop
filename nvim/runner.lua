-- Project run-script runner.
--
-- Streams a command's stdout/stderr into a persistent scratch buffer placed
-- in the layout's secondary window. Lines are parsed through errorformat into
-- quickfix as they arrive. Focus returns to primary after launch.
--
-- The output buffer is created once and reused across runs (cleared at the
-- start of each). It stays in whichever window it ended up in, so we don't
-- evict the user's edits more than once.

local layout = require('layout')

local M = {}

local OUTPUT_BUF_TAG = 'workshop_output_buf'
local OUTPUT_BUF_NAME = '[command-output]'

local DEFAULT_EFM = table.concat({
    '%f:%l:%c: %t%*[^:]: %m', -- clang-style
    '%A%f:%l:%c',             -- TS/JS first line
    '%ZError: %m',
    '%C%.%#',
    '%-G%.%#',
}, ',')

local state = {
    job_id = nil,
    buf = nil,
    partial_stdout = '',
    partial_stderr = '',
    notif_id = nil,
    line_count = 0,
    cmd_label = '',
}

local function mini_notify()
    local ok, m = pcall(require, 'mini.notify')
    if ok then return m end
end

local function notif_msg()
    return string.format('runner: %s · %d lines', state.cmd_label, state.line_count)
end

local function notif_start(cmd)
    state.line_count = 0
    state.cmd_label = type(cmd) == 'table' and table.concat(cmd, ' ') or tostring(cmd)
    local m = mini_notify()
    if m then state.notif_id = m.add(notif_msg(), 'INFO') end
end

local function notif_bump(added)
    if not state.notif_id then return end
    state.line_count = state.line_count + added
    local m = mini_notify()
    if m then pcall(m.update, state.notif_id, { msg = notif_msg() }) end
end

local function notif_finish()
    if not state.notif_id then return end
    local m = mini_notify()
    if m then pcall(m.remove, state.notif_id) end
    state.notif_id = nil
end

local function strip_ansi(line)
    return (line:gsub('[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]', ''))
end

local function wsl_paths(line)
    return (line:gsub('C:\\', '/mnt/c/'))
end

local function split_clang_failed(line)
    local marker = 'clang failed with stderr: '
    local i1, i2 = line:find(marker, 1, true)
    if not i1 then return line end
    return { line:sub(1, i2), line:sub(i2 + 1) }
end

local function rtrim(s)
    return (s:gsub('%s+$', ''))
end

M.filters = { strip_ansi, wsl_paths, split_clang_failed }

local function apply_filters(lines)
    local out = {}
    for _, line in ipairs(lines) do
        local cur = { rtrim(line) }
        for _, f in ipairs(M.filters) do
            local nxt = {}
            for _, l in ipairs(cur) do
                local r = f(l)
                if type(r) == 'table' then
                    for _, x in ipairs(r) do table.insert(nxt, x) end
                else
                    table.insert(nxt, r)
                end
            end
            cur = nxt
        end
        for _, l in ipairs(cur) do table.insert(out, l) end
    end
    return out
end

local function append_to_quickfix(lines, efm)
    if #lines == 0 then return end
    local qf = vim.fn.getqflist({ efm = efm, lines = lines })
    if qf.items and #qf.items > 0 then
        vim.fn.setqflist(qf.items, 'a')
    end
end

local function buf_is_empty(buf)
    return vim.api.nvim_buf_line_count(buf) == 1
        and (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or '') == ''
end

local function append_to_buf(buf, lines)
    if not vim.api.nvim_buf_is_valid(buf) or #lines == 0 then return end
    if buf_is_empty(buf) then
        vim.api.nvim_buf_set_lines(buf, 0, 1, false, lines)
    else
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    end
    -- Auto-scroll any window showing this buffer.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
            local line_count = vim.api.nvim_buf_line_count(buf)
            pcall(vim.api.nvim_win_set_cursor, win, { line_count, 0 })
        end
    end
end

-- Split a stream chunk into complete lines plus a remaining partial.
-- jobstart chunking: chunks[1] continues the in-progress line; with only one
-- element, it's still partial; otherwise 1..N-1 are complete and N is partial.
local function consume_stream(chunks, partial)
    if not chunks or #chunks == 0 then return {}, partial end
    chunks[1] = partial .. chunks[1]
    if #chunks == 1 then
        return {}, chunks[1]
    end
    local complete = {}
    for i = 1, #chunks - 1 do
        table.insert(complete, chunks[i])
    end
    return complete, chunks[#chunks]
end

local function process_stream(chunks, partial_key, efm)
    local complete, partial = consume_stream(chunks, state[partial_key])
    state[partial_key] = partial
    if #complete == 0 then return end
    local filtered = apply_filters(complete)
    append_to_buf(state.buf, filtered)
    append_to_quickfix(filtered, efm)
    notif_bump(#filtered)
end

local function flush_partials(efm)
    local tail = {}
    if state.partial_stdout ~= '' then
        table.insert(tail, state.partial_stdout)
        state.partial_stdout = ''
    end
    if state.partial_stderr ~= '' then
        table.insert(tail, state.partial_stderr)
        state.partial_stderr = ''
    end
    if #tail == 0 then return end
    local filtered = apply_filters(tail)
    append_to_buf(state.buf, filtered)
    append_to_quickfix(filtered, efm)
    notif_bump(#filtered)
end

local function is_running()
    return state.job_id ~= nil
end

function M.stop()
    if not is_running() then return end
    pcall(vim.fn.jobstop, state.job_id)
end

local function ensure_output_buf()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        return state.buf
    end
    local buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch
    vim.b[buf][OUTPUT_BUF_TAG] = true
    vim.bo[buf].bufhidden = 'hide'
    vim.bo[buf].buflisted = false
    vim.bo[buf].swapfile = false
    pcall(vim.api.nvim_buf_set_name, buf, OUTPUT_BUF_NAME)

    -- Kill the job if the buffer ever gets wiped.
    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = buf,
        callback = function()
            M.stop()
            state.buf = nil
        end,
    })

    state.buf = buf
    return buf
end

local function clear_output_buf(buf)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
end

local function output_window()
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return nil end
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == state.buf then return win end
    end
    return nil
end

-- Place the output buffer in secondary, evicting whatever was there.
-- Only called when output buffer isn't already visible.
local function show_output_in_secondary(buf)
    local win = layout.get_window('secondary', { create = true })
    if not win then return nil end

    -- If we're sitting in secondary, move its current buffer to primary so we
    -- don't lose the user's edit slot.
    if vim.api.nvim_get_current_win() == win then
        local prim = layout.get_window('primary', { create = true })
        if prim and prim ~= win then
            local b = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_win_set_buf(prim, b)
        end
    end

    vim.api.nvim_win_set_buf(win, buf)
    return win
end

function M.run(command, opts)
    opts = opts or {}
    local efm = opts.efm or DEFAULT_EFM

    if is_running() then M.stop() end

    state.partial_stdout = ''
    state.partial_stderr = ''

    local buf = ensure_output_buf()
    if not output_window() then
        if not show_output_in_secondary(buf) then
            vim.notify('runner: could not get secondary window', vim.log.levels.ERROR)
            return
        end
    end

    clear_output_buf(buf)
    vim.fn.setqflist({}, 'r')

    local job_id = vim.fn.jobstart(command, {
        on_stdout = function(_, data)
            process_stream(data, 'partial_stdout', efm)
        end,
        on_stderr = function(_, data)
            process_stream(data, 'partial_stderr', efm)
        end,
        on_exit = function(_, exit_code)
            flush_partials(efm)
            state.job_id = nil
            notif_finish()
            local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
            vim.notify(string.format('exit %d: %s', exit_code, command), level, { title = 'runner' })
            if opts.on_exit then opts.on_exit(exit_code) end
        end,
        stdout_buffered = false,
        stderr_buffered = false,
    })

    if job_id <= 0 then
        vim.notify('runner: jobstart failed', vim.log.levels.ERROR)
        return
    end
    state.job_id = job_id
    notif_start(command)

    -- Focus primary so the user can keep editing.
    local prim = layout.get_window('primary', { create = true })
    if prim then vim.api.nvim_set_current_win(prim) end
end

function M.setup()
    vim.api.nvim_create_user_command('Run', function(args)
        M.run(args.args)
    end, { nargs = '*' })
    vim.api.nvim_create_user_command('RunStop', function() M.stop() end, {})
end

return M
