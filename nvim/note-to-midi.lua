-- Musical Note to MIDI Number Converter for Neovim
-- Add this to your init.lua or a separate plugin file

-- Configuration: Set the octave number for middle C (C4 = MIDI 60)
-- Most common: 4 (C4 = middle C), but some use 3 (C3 = middle C)
local MIDDLE_C_OCTAVE = 4

-- Note name to semitone mapping (C = 0)
local NOTE_TO_SEMITONE = {
    c = 0, d = 2, e = 4, f = 5, g = 7, a = 9, b = 11
}

-- Function to convert note name to MIDI number
local function note_to_midi(note_str)
    print(note_str)
    -- Parse the note string (e.g., "C#4", "Bb2", "f3")
    local note_pattern = "^([a-gA-G])([#b]?)(-?%d+)$"
    local note_letter, accidental, octave_str = note_str:match(note_pattern)

    if not note_letter then
        return nil, "Invalid note format. Use format like 'C4', 'F#3', 'Bb2'"
    end

    -- Convert to lowercase for lookup
    note_letter = note_letter:lower()
    local octave = tonumber(octave_str)

    if not octave then
        return nil, "Invalid octave number"
    end

    -- Get base semitone value
    local semitone = NOTE_TO_SEMITONE[note_letter]
    if not semitone then
        return nil, "Invalid note letter"
    end

    -- Apply accidental
    if accidental == "#" then
        semitone = semitone + 1
    elseif accidental == "b" then
        semitone = semitone - 1
    end

    -- Calculate MIDI number
    -- MIDI note 60 = C4 (middle C) in most systems
    local midi_c0 = 60 - (MIDDLE_C_OCTAVE * 12) -- MIDI number for C0
    local midi_number = midi_c0 + (octave * 12) + semitone

    -- MIDI range is 0-127
    if midi_number < 0 or midi_number > 127 then
        return nil, "MIDI number out of range (0-127): " .. midi_number
    end

    return midi_number
end

local function convert_note_under_cursor()
    -- Get current cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2] -- Convert to 0-based indexing

    -- Get current line
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    if not line then return end

    -- Note names are 2-4 characters: minimum "C0", maximum "C#10"
    -- Search in a window around the cursor position
    local search_start = math.max(1, col - 2)   -- Start up to 3 positions before cursor
    local search_end = math.min(#line, col + 4) -- End up to 4 positions after cursor

    local best_match = nil
    local best_start = nil
    local best_end = nil

    -- Try all possible positions within our search window
    for start_pos = search_start, col + 1 do
        for length = 2, 4 do
            local end_pos = start_pos + length - 1
            if end_pos <= search_end and end_pos <= #line then
                local candidate = line:sub(start_pos, end_pos)
                -- Check if this looks like a note pattern
                if candidate:match("^[a-gA-G][#b]?%-?%d+$") then
                    -- Check if cursor is within this candidate
                    if col >= start_pos - 1 and col <= end_pos - 1 then
                        best_match = candidate
                        best_start = start_pos
                        best_end = end_pos
                        break
                    end
                end
            end
        end
        if best_match then break end
    end

    if not best_match then
        vim.notify("No note found under cursor", vim.log.levels.WARN)
        return
    end

    -- Convert note to MIDI
    local midi_number, error_msg = note_to_midi(best_match)
    if not midi_number then
        vim.notify("Error: " .. error_msg .. " (found: '" .. best_match .. "')", vim.log.levels.ERROR)
        return
    end

    -- Replace the note with MIDI number
    local new_line = line:sub(1, best_start - 1) .. tostring(midi_number) .. line:sub(best_end + 1)
    vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })

    -- Adjust cursor position to end of replaced number
    local new_col = best_start - 1 + #tostring(midi_number)
    vim.api.nvim_win_set_cursor(0, { row + 1, new_col })

    vim.notify("Converted '" .. best_match .. "' to MIDI " .. midi_number, vim.log.levels.INFO)
end

-- Create user command
vim.api.nvim_create_user_command('NoteToMidi', convert_note_under_cursor, {
    desc = 'Convert musical note under cursor to MIDI number'
})

-- Create keymap (you can change this to your preference)
vim.keymap.set('n', '<leader>nm', convert_note_under_cursor, {
    desc = 'Convert note to MIDI number',
    silent = true
})

-- Make it repeatable with vim-repeat plugin (if you have it installed)
-- This allows you to use '.' to repeat the operation
vim.api.nvim_create_autocmd('User', {
    pattern = 'repeat_set',
    callback = function()
        vim.fn['repeat#set']('\\<Plug>NoteToMidi', vim.v.count)
    end
})

-- Create a plug mapping for repeatability
vim.keymap.set('n', '<Plug>NoteToMidi', function()
    convert_note_under_cursor()
    -- Set up for repeat
    vim.cmd('silent! call repeat#set("\\<Plug>NoteToMidi", ' .. vim.v.count1 .. ')')
end, { silent = true })

-- Alternative keymap using the plug mapping (for repeatability)
vim.keymap.set('n', '<leader>nm', '<Plug>NoteToMidi', {
    desc = 'Convert note to MIDI number (repeatable)',
    silent = true
})

-- Configuration function to change middle C octave
local function set_middle_c_octave(octave)
    MIDDLE_C_OCTAVE = octave
    vim.notify("Middle C octave set to " .. octave .. " (C" .. octave .. " = MIDI 60)", vim.log.levels.INFO)
end

-- Command to configure middle C octave
vim.api.nvim_create_user_command('SetMiddleCOctave', function(opts)
    local octave = tonumber(opts.args)
    if octave and octave >= 0 and octave <= 10 then
        set_middle_c_octave(octave)
    else
        vim.notify("Invalid octave. Please provide a number between 0 and 10.", vim.log.levels.ERROR)
    end
end, {
    nargs = 1,
    desc = 'Set the octave number for middle C (default: 4)',
    complete = function() return { '3', '4', '5' } end
})

-- Export functions for external use
return {
    note_to_midi = note_to_midi,
    convert_note_under_cursor = convert_note_under_cursor,
    set_middle_c_octave = set_middle_c_octave
}
