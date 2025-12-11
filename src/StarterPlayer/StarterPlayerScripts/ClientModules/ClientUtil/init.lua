local ClientUtil = {}

function ClientUtil:Init() end

function ClientUtil:WaitForDescendants(root, ...)
	local names = { ... }
	local current = root

	for _, name in ipairs(names) do
		current = current:WaitForChild(name)

		while not current do
			current = current:WaitForChild(name)
		end
	end

	return current
end

function ClientUtil:Color3(a, b, c)
	return Color3.new(a / 255, b / 255, c / 255)
end

function ClientUtil:FormatToUSD(number)
	-- Arredonda o número (use math.floor se quiser truncar)
	number = math.floor(number + 0.5)

	-- Converte para string sem decimais
	local formatted = string.format("%d", number)

	-- Adiciona vírgulas a cada 3 dígitos
	formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()

	-- Remove vírgula no início, se aparecer
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end

	return "$" .. formatted
end

function ClientUtil:FormatSecondsToMinutes(seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%02dm:%02ds", minutes, remainingSeconds)
end

function ClientUtil:FormatNumberToSuffixes(n)
	local suffixes = { "", "K", "M", "B", "T", "Q" } -- pode adicionar mais se quiser
	local i = 1

	while n >= 1000 and i < #suffixes do
		n = n / 1000
		i = i + 1
	end

	-- Limita para 1 casa decimal e remove .0 se for inteiro
	local formatted = string.format("%.1f", n)
	formatted = formatted:gsub("%.0$", "")

	return formatted .. suffixes[i]
end

return ClientUtil
