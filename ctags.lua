local function find_tags(path)
	for i = #path, 1, -1 do
		if path:sub(i, i) == '/' then
			local prefix = path:sub(1, i)
			local filename = prefix .. 'tags'
			local file = io.open(filename, 'r')

			if file ~= nil then
				file:close()
				return filename, prefix
			end
		end
	end
end

local function get_query(str, pos)
	local from, to = 0, 0
	while pos > to do
		from, to = str:find('[%a_]+[%a%d_]*', to + 1)
		if from == nil or from > pos then
			return nil
		end
	end

	return string.sub(str, from, to)
end

local function search(word, full)
	local filepath = vis.win.file.path
	local records = {}
	local filename, pattern
	local tagfile, prefix = find_tags(filepath)
	local cmd = string.format('readtags -t %s %s', tagfile, word)
	local tmp = io.popen(cmd)
	local i = 0
	for line in tmp:lines() do
		records[i] = line
		i = i + 1
	end
	tmp:close()
	return records, i, prefix
end

vis:map(vis.modes.NORMAL, '<C-]>', function(keys)
	local line = vis.win.selection.line
	local col = vis.win.selection.col
	local query = get_query(vis.win.file.lines[line], col)
	
	local out, sz, prefix = search(query)
	if sz == 1 then
		local filename, pattern = string.match(out[0], "[^\t]+\t+([^\t]+)\t+(.*)")
		local cmd = string.format("open '%s'", prefix..filename)
		vis:command(cmd)
		vis:command(pattern)
	elseif sz > 1 then
		vis:command("new")
		vis.win.file:insert(0, table.concat(out, "\n"))
		vis:command("0")
	else
		vis:info(string.format('Tag not found: %s', query))
	end
end)
