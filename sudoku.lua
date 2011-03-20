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

function print_array(arr)
	io.write("[")
	for k=1,#arr do
		if type(arr[k]) == "number" then
			io.write(string.format("%d", arr[k]))
		else
			print_array(arr[k])
		end
		if k ~= #arr then
			io.write(", ")
		end
	end
	io.write("]")
end

function print_field(field)
	local length = (#field)^0.5
	for i=0,length-1 do
		for j=1,length do
			local current = i*length+j
			if type(field[current]) == "number" then
				io.write(string.format("%d", field[current]))
			else
				print_array(field[current])
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

calculate_row = function(length, row, pos)
	return (row-1)*length + pos
end

calculate_col = function(length, col, pos)
	return (pos-1)*length + col
end

calculate_block = function(length, block, pos)
	local sq_len = length^0.5
	local block_start = ((block-1)%sq_len) * sq_len +
		div(block, sq_len) * length * sq_len
	return block_start + mod_n(pos, sq_len) + (length * div(pos, sq_len))
end

function compute_possibilities(field)
	local length = (#field)^0.5
	local sq_len = length^0.5
	while #queue > 0 do
		i = queue[1]
		local current_val = field[i]
		local block = 1 + (div(i, sq_len) % sq_len) + 
			math.floor(div(i, length) / sq_len) * sq_len
		for j=1,length do
			current_row = calculate_row(length, div(i, length) + 1, j)
			current_col = calculate_col(length, mod_n(i, length), j)
			current_block = calculate_block(length, block , j)
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

function one_possibility_in_cell(field)
	function calculate_single(field, calculate_current) 
		local length = (#field)^0.5
		for n=1,length do
			local found = {}
			for i=1,length do
				local current = calculate_current(length, n, i)
				if type(field[current]) == "table" then
					for _, num in pairs(field[current]) do
						if found[num] then
							found[num][#found[num]+1] = current
						else
							found[num] = {current}
						end
					end
				else
					local num = field[current]
					if found[num] then
						found[num][#found[num]+1] = current
					else
						found[num] = {current}
					end
				end
			end
			for num, where in pairs(found) do
				if type(where) == "table" and #where == 1 then
					field[where[1]] = num
					if not verify_solution(field) then
						print("Caused error!")
						print_field(field)
						os.exit()
					end
				end
			end
		end
	end

	calculate_single(field, calculate_row)
	if not verify_solution(field) then
		print("Error after row")
	end
	calculate_single(field, calculate_col)
	if not verify_solution(field) then
		print("Error after col")
	end
	calculate_single(field, calculate_block)
	if not verify_solution(field) then
		print("Error after block")
	end

	return calculate_missing(field)
end

function verify_solution(field)
	function verify_cell(field, calculate_current)
		local length = (#field)^0.5
		for n=1,length do
			local found = {}
			for i=1,length do
				local current = calculate_current(length, n, i)
				if type(field[current]) == "table" then
					break
				end
				if found[field[current]] then
					print(string.format("Position %d: duplicate value %d in cell", current, field[current]))
					return false
				end
				found[field[current]] = true
			end
		end
		return true
	end
	return verify_cell(field, calculate_row) and verify_cell(field, calculate_col) and verify_cell(field, calculate_block)
end

prepare_field(field)

local iterations = 0
repeat
	local last_missing = missing
	missing = compute_possibilities(field)
	if not verify_solution(field) then
		print("Error after compute_possiblities")
		break
	end
	iterations = iterations + 1
	if last_missing == missing then
		missing = one_possibility_in_cell(field)
		if not verify_solution(field) then
			print("Error after one_possibility_in_cell")
			break
		end
	end
until missing == 0 or last_missing == missing

print_field(field)

if not verify_solution(field) then
	print("Error in solution")
else
	print(string.format("Solved in %d iterations", iterations))
end
