local field = {
	5, 3, 0, 0, 7, 0, 0, 0, 0,
	6, 0, 0, 1, 9, 5, 0, 0, 0,
	0, 9, 8, 0, 0, 0, 0, 6, 0,
	8, 0, 0, 0, 6, 0, 0, 0, 3,
	4, 0, 0, 8, 0, 3, 0, 0, 1,
	7, 0, 0, 0, 2, 0, 0, 0, 6,
	0, 6, 0, 0, 0, 0, 2, 8, 0,
	0, 0, 0, 4, 1, 9, 0, 0, 5,
	0, 0, 0, 0, 8, 0, 0, 7, 9
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
	local missing = 0
	for i=1,#field do
		if type(field[i]) ~= "number" then
			missing = missing + 1
		end
	end
	return missing
end

prepare_field(field)

local iterations = 0
repeat
	local last_missing = missing
	missing = compute_possibilities(field)
	iterations = iterations + 1
until missing == 0 or last_missing == missing

print_field(field)

print(string.format("Solved in %d iterations", iterations))
