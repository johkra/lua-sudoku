local field = {
	 6,  0,  0,  0,  0,  0,  0, 13,  0,  0,  0, 16,  0, 12,  0,  3,
	14,  0, 12,  0,  0,  0,  0,  6, 15,  0,  0,  0,  5,  0, 10,  0,
	 3,  0,  0,  0,  0, 11, 12,  5, 14,  0,  7,  1,  0,  0,  0,  0,
	10, 13,  7,  0,  0, 15,  0,  0,  0,  0,  4,  6, 14,  0,  0,  0,
	 8,  0,  2, 16,  0,  0,  0,  0,  0,  0, 14,  0,  6,  1,  0,  9,
	 0, 11,  0,  0,  0,  0,  0,  9,  0,  4,  0, 13,  8,  0,  0,  0,
	 0,  0,  5,  0,  0,  0,  0, 15,  0, 11,  8, 10,  0, 14,  7,  4,
	 1,  0, 10,  0,  0,  0,  8,  0,  0,  0,  0,  0, 15,  2, 11,  0,
	 0,  5, 16,  7,  0,  0,  0,  0,  0,  6,  0,  0,  0,  4,  0,  8,
	 4,  9,  8,  0,  3,  5, 16,  0, 11,  0,  0,  0,  0, 13,  0,  0,
	 0,  0,  0,  1,  9,  0, 10,  0, 13,  0,  0,  0,  0,  0,  3,  0,
	13,  0,  3, 10,  0, 12,  0,  0,  0,  0,  0,  0,  7, 15,  0,  1,
	 0,  0,  0, 14, 15, 10,  0,  0,  0,  0,  1,  0,  0,  5, 12, 13,
	 0,  0,  0,  0, 14, 16,  0,  1,  7,  8,  3,  0,  0,  0,  0,  6,
	 0,  2,  0,  4,  0,  0,  0,  3,  6,  0,  0,  0,  0, 11,  0,  7,
	 5,  0,  6,  0, 11,  0,  0,  0, 10,  0,  0,  0,  0,  0,  0, 15
}

local queue = {}

function print_field(field)
	local length = (#field)^0.5
	for i=0,length-1 do
		for j=1,length do
			local current = i*length+j
			if type(field[current]) == "number" then
				io.write(string.format("%d", field[current]))
			else
				local arr = field[current]
				io.write("[")
				for k=1,#arr do
					io.write(string.format("%d", arr[k]))
					if k ~= #arr then
						io.write(",")
					end
				end
				io.write("]")
			end
			if (j ~= length) then
				io.write("\t")
			end
		end
		io.write("\n")
	end
end

function prepare_field(field)
	local length = (#field)^0.5
	
	local all_num = {}
	for i=1,length do
		all_num[i] = i
	end

	for i=1,#field do
		if field[i] == 0 then
			field[i] = all_num
		else
			queue[#queue+1] = i
		end
	end
end

function remove_num(arr, num)
	if type(arr) == "number" then
		return arr, false
	end

	new_arr = {}
	for i=1,#arr do
		if (arr[i] ~= num) then
			new_arr[#new_arr+1] = arr[i]
		end
	end
	if #new_arr == 1 then
		return new_arr[1], true
	end
	return new_arr, false
end

function div(num, n)
	return math.floor((num-1) / n)
end

function mod_n(num, n)
	local mod = num % n
	if mod == 0 then
		mod = n
	end
	return mod
end

function calculate_missing(field)
	local missing = 0
	for i=1,#field do
		if type(field[i]) ~= "number" then
			missing = missing + 1
		end
	end
	return missing
end

function compute_possibilities(field)
	local length = (#field)^0.5
	local sq_len = length^0.5
	while #queue > 0 do
		i = queue[1]
		local current_val = field[i]
		local row = div(i, length)
		local col = mod_n(i, length)
		local block_start = ((div(i, sq_len) % sq_len) * sq_len) + 
			math.floor(div(i, length) / sq_len) * length * sq_len
		for j=1,length do
			current_row = row*length + j
			current_col = (j-1)*length + col
			current_block = block_start + mod_n(j, sq_len) + (length * div(j, sq_len))
			for _, l in ipairs({current_row, current_col, current_block}) do
				field[l], add_to_queue = remove_num(field[l], current_val)
				if add_to_queue then
					queue[#queue+1] = l
				end
			end
		end
		-- TODO: Use more efficient way to implement queue.
		local old_queue = queue
		queue = {}
		for i = 1,#old_queue-1 do
			queue[i] = old_queue[i+1]
		end
	end
	return calculate_missing(field)
end

function calculate_single(field, calculate_current) 
	local length = (#field)^0.5
	for n=1,length do
		local found = {}
		for i=1,length do
			local current = calculate_current(length, n, i)
			if current > 256 then
				print(string.format("%d: %d, %d, %d", current, length, n, i))
			end
			if type(field[current]) == "table" then
				for _, num in pairs(field[current]) do
					if type(found[num]) == "number" then
						break
					end
					if found[num] then
						found[num][#found[num]] = current
					else
						found[num] = {current}
					end
				end
			else
				found[field[current]] = current
			end
		end
		for num, where in pairs(found) do
			if type(where) == "table" and #where == 1 then
				field[where[1]] = num
			end
		end
	end
end

function one_possibility_in_cell(field)
	calculate_row = function(length, row, pos)
		return (row-1)*length + pos
	end
	calculate_single(field, calculate_row)
	calculate_col = function(length, col, pos)
		return (pos-1)*length + col
	end
	calculate_single(field, calculate_col)
	calculate_block = function(length, block, pos)
		local sq_len = length^0.5
		local block_start = ((block-1)%sq_len) * sq_len +
			div(block, sq_len) * length * sq_len
		return block_start + mod_n(pos, sq_len) + (length * div(pos, sq_len))
	end
	calculate_single(field, calculate_block)

	return calculate_missing(field)
end

prepare_field(field)

local iterations = 0
repeat
	local last_missing = missing
	missing = compute_possibilities(field)
	iterations = iterations + 1
	if last_missing == missing then
		missing = one_possibility_in_cell(field)
	end
until missing == 0 or last_missing == missing

print_field(field)

print(string.format("Solved in %d iterations", iterations))
