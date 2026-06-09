local M = {}

local function soxi_info(path)
	local child = Command("soxi"):arg(path):stdout(Command.PIPED):spawn()
	if not child then return nil end
	local output = child:wait_with_output()
	if not output or not output.status.success then return nil end

	local info = {}
	for line in output.stdout:gmatch("[^\r\n]+") do
		local k, v = line:match("^([^:]+):%s*(.+)$")
		if k and v then info[k:gsub("%s+$", "")] = v end
	end
	return info
end

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache or self:preload(job) ~= 1 then
		return
	end
	ya.sleep(math.max(0, 0.1 + start - os.clock()))

	local info = soxi_info(tostring(job.file.url))
	local lines = {}
	if info then
		local fields = { "Channels", "Sample Rate", "Precision", "Duration", "File Size", "Bit Rate", "Sample Encoding" }
		for _, k in ipairs(fields) do
			if info[k] then
				lines[#lines + 1] = ui.Line { ui.Span(k .. ": "):bold(), ui.Span(info[k]) }
			end
		end
	end

	local header_h = math.min(#lines, math.max(0, job.area.h - 4))
	local text_area = ui.Rect { x = job.area.x, y = job.area.y, w = job.area.w, h = header_h }
	local image_area = ui.Rect {
		x = job.area.x,
		y = job.area.y + header_h,
		w = job.area.w,
		h = job.area.h - header_h,
	}

	ya.image_show(cache, image_area)
	ya.preview_widget(job, ui.Text(lines):area(text_area))
end


function M:seek(job, units)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = ya.clamp(-1, units, 1)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

function M:preload(job)
	if not job then
		return 1
	end

	local percentage = 5 + job.skip
	if percentage > 95 then
		ya.emit("peek", { 90, only_if = job.file.url, upper_bound = true })
		return 2
	end
	local cache = ya.file_cache(job)
	if not cache then
		return 1
	end

	local cha = fs.cha(cache)
	if cha and cha.len > 0 then
		return 1
	end

	local child, code = Command("sox")
		:arg({tostring(job.file.url),
		     "-n", "trim", "0:00", "1:00",
		     "remix", "1",
		     "rate", "12k",
		     "spectrogram",
		     "-o", tostring(cache)})
		:spawn()

	if not child then
		ya.err("spawn `sox` command returns " .. tostring(code))
		return 0
	end

	local status = child:wait()
	return status and status.success and 1 or 2
end

return M
