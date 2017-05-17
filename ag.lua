-- search the keyword under cursor using ag

vis:map(vis.modes.NORMAL, "K", function()
	local win = vis.win
	local file = win.file
	local pos = win.cursor.pos
	if not pos then return end
	-- TODO do something clever here
	local range = file:text_object_word(pos > 0 and pos-1 or pos);
	if not range then return end
	if range.start == range.finish then return end
	local keyword = file:content(range)
	if not keyword then return end
	local cmd = string.format("ag --vimgrep '%s'", keyword)
	vis:message(cmd .. "\n")
	local status, out, err = vis:pipe(file, { start = 0, finish = 0 }, cmd)
	if status ~= 0 or not out then
		if err then vis:info(err) end
		return
	end
	vis:message(out)
end, "Complete keyword search")

