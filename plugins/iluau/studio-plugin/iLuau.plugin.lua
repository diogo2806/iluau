local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local BASE_URL = "http://127.0.0.1:3099"
local CLIENT_ID = HttpService:GenerateGUID(false)
local CLIENT_NAME = "iLuau Studio"
local POLL_INTERVAL = 1.5
local running = true

local toolbar = plugin:CreateToolbar("iLuau")
local toggleButton = toolbar:CreateButton("iLuauPanel", "Toggle the iLuau panel", "")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true,
	true,
	420,
	560,
	320,
	420
)
local widget = plugin:CreateDockWidgetPluginGui("iLuauPanel", widgetInfo)
widget.Title = "iLuau"

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
root.BorderSizePixel = 0
root.Parent = widget

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 56)
topBar.BackgroundColor3 = Color3.fromRGB(22, 27, 38)
topBar.BorderSizePixel = 0
topBar.Parent = root

local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, 0, 0, 2)
topAccent.BackgroundColor3 = Color3.fromRGB(124, 247, 212)
topAccent.BorderSizePixel = 0
topAccent.Parent = topBar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -24, 0, 24)
title.Position = UDim2.new(0, 12, 0, 10)
title.Font = Enum.Font.GothamBold
title.Text = "iLuau"
title.TextColor3 = Color3.fromRGB(240, 244, 248)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(1, -24, 0, 18)
subtitle.Position = UDim2.new(0, 12, 0, 30)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Roblox Studio bridge and queue"
subtitle.TextColor3 = Color3.fromRGB(145, 156, 171)
subtitle.TextSize = 12
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topBar

local statusBadge = Instance.new("TextLabel")
statusBadge.AnchorPoint = Vector2.new(1, 0)
statusBadge.BackgroundColor3 = Color3.fromRGB(48, 58, 78)
statusBadge.BorderSizePixel = 0
statusBadge.Position = UDim2.new(1, -12, 0, 14)
statusBadge.Size = UDim2.new(0, 120, 0, 26)
statusBadge.Font = Enum.Font.GothamSemibold
statusBadge.Text = "disconnected"
statusBadge.TextColor3 = Color3.fromRGB(230, 236, 241)
statusBadge.TextSize = 12
statusBadge.Parent = topBar

local body = Instance.new("ScrollingFrame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 0, 0, 56)
body.Size = UDim2.new(1, 0, 1, -56)
body.ScrollBarThickness = 6
body.BorderSizePixel = 0
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = root

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.Parent = body

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = body

local function makeCard(height)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, height)
	card.BackgroundColor3 = Color3.fromRGB(22, 27, 38)
	card.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(51, 63, 82)
	stroke.Thickness = 1
	stroke.Transparency = 0.35
	stroke.Parent = card

	return card
end

local function makeSectionTitle(parent, text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -20, 0, 18)
	label.Position = UDim2.new(0, 10, 0, 8)
	label.Font = Enum.Font.GothamSemibold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(232, 238, 247)
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makeStat(parent, text, value, topOffset)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(0, 90, 0, 18)
	titleLabel.Position = UDim2.new(0, 10, 0, topOffset)
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.Text = text
	titleLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
	titleLabel.TextSize = 12
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = parent

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size = UDim2.new(1, -110, 0, 18)
	valueLabel.Position = UDim2.new(0, 100, 0, topOffset)
	valueLabel.Font = Enum.Font.GothamSemibold
	valueLabel.Text = value
	valueLabel.TextColor3 = Color3.fromRGB(240, 244, 248)
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.Parent = parent

	return valueLabel
end

local function makeButton(parent, text, onClick)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 0, 0, 30)
	button.AutomaticSize = Enum.AutomaticSize.X
	button.BackgroundColor3 = Color3.fromRGB(124, 247, 212)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamSemibold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(8, 16, 22)
	button.TextSize = 12
	button.AutoButtonColor = true

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	button.MouseButton1Click:Connect(onClick)
	button.Parent = parent
	return button
end

local function stylePillButton(button, isActive, compact)
	button.AutoButtonColor = true
	button.BackgroundColor3 = isActive and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(28, 34, 46)
	button.TextColor3 = isActive and Color3.fromRGB(8, 16, 22) or Color3.fromRGB(232, 238, 247)
	button.BorderSizePixel = 0

	local stroke = button:FindFirstChildOfClass("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Parent = button
	end
	stroke.Color = isActive and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(58, 72, 94)
	stroke.Thickness = 1
	stroke.Transparency = isActive and 0.1 or 0.35

	local corner = button:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = button
	end
	corner.CornerRadius = UDim.new(0, compact and 8 or 10)
end

local function makePillButton(parent, text, onClick, isActive, compact)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 0, 0, compact and 26 or 30)
	button.AutomaticSize = Enum.AutomaticSize.X
	button.Font = Enum.Font.GothamSemibold
	button.Text = text
	button.TextSize = compact and 11 or 12

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, compact and 10 or 12)
	padding.PaddingRight = UDim.new(0, compact and 10 or 12)
	padding.Parent = button

	stylePillButton(button, isActive, compact)

	button.MouseButton1Click:Connect(onClick)
	button.Parent = parent
	return button
end

local function makeTextBox(parent, placeholder, height)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 0, height)
	box.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.MultiLine = true
	box.Text = ""
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(104, 115, 129)
	box.Font = Enum.Font.Code
	box.TextColor3 = Color3.fromRGB(240, 244, 248)
	box.TextSize = 12
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = box

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = box

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(51, 63, 82)
	stroke.Thickness = 1
	stroke.Transparency = 0.35
	stroke.Parent = box

	box.Parent = parent
	return box
end

local function request(method, path, body)
	local options = {
		Url = BASE_URL .. path,
		Method = method,
		Headers = {
			["Content-Type"] = "application/json",
		},
	}

	if body then
		options.Body = HttpService:JSONEncode(body)
	end

	return HttpService:RequestAsync(options)
end

local function safeRequest(method, path, body)
	local ok, response = pcall(request, method, path, body)
	if ok and response then
		return response
	end
	return nil
end

local function findByPath(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end
	local current = game
	for token in string.gmatch(path, "[^%.]+") do
		if token == "game" then
			current = game
		else
			current = current and current:FindFirstChild(token)
		end
		if not current then
			return nil
		end
	end
	return current
end

local function serializeSelection()
	local items = {}
	for _, item in ipairs(Selection:Get()) do
		table.insert(items, {
			name = item.Name,
			className = item.ClassName,
			path = item:GetFullName(),
		})
	end
	return items
end

local function readProperties(target, propertyNames)
	local values = {}
	for _, propertyName in ipairs(propertyNames or {}) do
		local ok, value = pcall(function()
			return target[propertyName]
		end)
		values[propertyName] = ok and value or nil
	end
	return values
end

local selectionSummaryLabel
local selectionList
local selectionTreeFilterBox
local selectionTreeFilterStatusLabel
local selectionTreeActionsRow
local selectionTargetLabel
local selectionPropertyNameBox
local selectionPropertyValueBox
local selectionPropertyStatusLabel
local selectionPropertyTypeLabel
local selectionPropertyQuickRow
local selectionPropertyHistoryList
local selectionPropertyHistoryStatusLabel
local selectionPropertyOutcomeLabel
local selectionPropertyFavoriteRow
local selectionPropertyFavoritesStatusLabel
local selectionAttributesBox
local selectionTagsBox
local selectionStatusLabel
local refreshSelectionTree
local treeExpansion = {}
local propertyHistory = {}
local propertyHistoryByKey = {}
local propertyFavorites = {}
local propertyFavoritesSet = {}
local selectionTreeFilterText = ""
local PROPERTY_HISTORY_LIMIT = 12
local PROPERTY_STATE_KEY = "iLuau.propertyHistory.v1"
local PROPERTY_EDITOR_STATE_KEY = "iLuau.propertyEditor.v1"
local PROPERTY_FAVORITES_KEY = "iLuau.propertyFavorites.v1"
local TREE_FILTER_KEY = "iLuau.treeFilter.v1"
local QUICK_READ_PROPERTIES = {
	"Name",
	"Parent",
	"Visible",
	"Transparency",
	"Position",
	"Size",
	"Anchored",
	"CanCollide",
	"Text",
	"BackgroundColor3",
	"Color",
}
local formatPropertyValue

local function nowIso()
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function loadPluginState(key, fallback)
	local ok, value = pcall(function()
		return plugin:GetSetting(key)
	end)
	if ok and value ~= nil then
		return value
	end
	return fallback
end

local function savePluginState(key, value)
	pcall(function()
		plugin:SetSetting(key, value)
	end)
end

local function normalizeNameKey(value)
	return string.lower(trim(tostring(value or "")))
end

local function isFavoriteProperty(propertyName)
	return propertyFavoritesSet[normalizeNameKey(propertyName)] == true
end

local function savePropertyFavorites()
	savePluginState(PROPERTY_FAVORITES_KEY, propertyFavorites)
end

local function rebuildPropertyFavoritesSet()
	propertyFavoritesSet = {}
	for _, propertyName in ipairs(propertyFavorites) do
		local key = normalizeNameKey(propertyName)
		if key ~= "" then
			propertyFavoritesSet[key] = true
		end
	end
end

local function setPropertyFavorite(propertyName, enabled)
	local key = normalizeNameKey(propertyName)
	if key == "" then
		return
	end

	if enabled then
		if not propertyFavoritesSet[key] then
			table.insert(propertyFavorites, propertyName)
			propertyFavoritesSet[key] = true
		end
	else
		local nextFavorites = {}
		for _, existing in ipairs(propertyFavorites) do
			if normalizeNameKey(existing) ~= key then
				table.insert(nextFavorites, existing)
			end
		end
		propertyFavorites = nextFavorites
		rebuildPropertyFavoritesSet()
	end

	savePropertyFavorites()
end

local function getPropertyFavorites()
	return propertyFavorites
end

local function loadPropertyFavorites()
	local loaded = loadPluginState(PROPERTY_FAVORITES_KEY, {})
	if type(loaded) == "table" then
		propertyFavorites = {}
		local seen = {}
		for _, propertyName in ipairs(loaded) do
			local key = normalizeNameKey(propertyName)
			if type(propertyName) == "string" and trim(propertyName) ~= "" and key ~= "" and not seen[key] then
				seen[key] = true
				table.insert(propertyFavorites, propertyName)
			end
		end
	else
		propertyFavorites = {}
	end
	rebuildPropertyFavoritesSet()
end

local function loadTreeFilter()
	local value = loadPluginState(TREE_FILTER_KEY, "")
	if type(value) == "string" then
		return value
	end
	return ""
end

local function saveTreeFilter(value)
	savePluginState(TREE_FILTER_KEY, value or "")
end

local function readAttributes(target)
	local ok, values = pcall(function()
		return target:GetAttributes()
	end)
	return ok and values or {}
end

local function setAttributes(target, attributes)
	for attributeName, value in pairs(attributes or {}) do
		pcall(function()
			target:SetAttribute(attributeName, value)
		end)
	end
end

local function readTags(target)
	local ok, values = pcall(function()
		return CollectionService:GetTags(target)
	end)
	return ok and values or {}
end

local function setTags(target, tags)
	local existing = {}
	for _, tag in ipairs(readTags(target)) do
		existing[tag] = true
	end

	local desired = {}
	for _, tag in ipairs(tags or {}) do
		desired[tag] = true
		if not existing[tag] then
			pcall(function()
				CollectionService:AddTag(target, tag)
			end)
		end
	end

	for tag in pairs(existing) do
		if not desired[tag] then
			pcall(function()
				CollectionService:RemoveTag(target, tag)
			end)
		end
	end
end

local function setProperties(target, properties)
	for propertyName, value in pairs(properties or {}) do
		pcall(function()
			target[propertyName] = value
		end)
	end
end

local function clearGuiRows(container)
	for _, child in ipairs(container:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

local function trim(value)
	if type(value) ~= "string" then
		return ""
	end
	return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function parseTagsText(text)
	local tags = {}
	local seen = {}
	for token in string.gmatch(text or "", "[^,\n]+") do
		local tag = trim(token)
		if tag ~= "" and not seen[tag] then
			seen[tag] = true
			table.insert(tags, tag)
		end
	end
	return tags
end

local function formatTagsText(tags)
	return table.concat(tags or {}, ", ")
end

local function encodeJsonSafe(value)
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(value)
	end)
	if ok then
		return encoded
	end
	return "{}"
end

local function parseAttributesText(text)
	local cleaned = trim(text or "")
	if cleaned == "" then
		return {}
	end

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(cleaned)
	end)
	if not ok then
		error("Attributes must be valid JSON")
	end
	if type(decoded) ~= "table" then
		error("Attributes must decode to a JSON object")
	end
	return decoded
end

local function selectInstance(instance)
	if not instance then
		return
	end
	pcall(function()
		Selection:Set({instance})
	end)
end

local function propertyHistoryKey(path, propertyName)
	return string.format("%s::%s", tostring(path or ""), tostring(propertyName or ""))
end

local function getFilterText()
	if selectionTreeFilterBox then
		return trim(selectionTreeFilterBox.Text or "")
	end
	return ""
end

local function nodeMatchesFilter(instance, filterText)
	if not instance then
		return false
	end

	local query = string.lower(trim(filterText or ""))
	if query == "" then
		return true
	end

	local name = string.lower(tostring(instance.Name or ""))
	local className = string.lower(tostring(instance.ClassName or ""))
	local fullName = string.lower(tostring(instance:GetFullName() or ""))

	return string.find(name, query, 1, true) ~= nil
		or string.find(className, query, 1, true) ~= nil
		or string.find(fullName, query, 1, true) ~= nil
end

local function nodeOrDescendantMatchesFilter(instance, filterText)
	if nodeMatchesFilter(instance, filterText) then
		return true
	end

	local ok, children = pcall(function()
		return instance:GetChildren()
	end)
	if not ok then
		return false
	end

	for _, child in ipairs(children) do
		if nodeOrDescendantMatchesFilter(child, filterText) then
			return true
		end
	end
	return false
end

local function setTreeExpansionForSelection(expanded)
	local roots = Selection:Get()
	local function walk(instance)
		if not instance then
			return
		end
		treeExpansion[instance] = expanded and true or false
		local ok, children = pcall(function()
			return instance:GetChildren()
		end)
		if ok then
			for _, child in ipairs(children) do
				walk(child)
			end
		end
	end

	for _, root in ipairs(roots) do
		walk(root)
	end
end

local function applyTreeFilter(text)
	saveTreeFilter(text or "")
	refreshSelectionTree()
end

local function renderPropertyFavorites()
	if not selectionPropertyFavoriteRow or not selectionPropertyFavoritesStatusLabel then
		return
	end

	clearGuiRows(selectionPropertyFavoriteRow)

	if #propertyFavorites == 0 then
		selectionPropertyFavoritesStatusLabel.Text = "Pinned properties"
		local empty = Instance.new("TextLabel")
		empty.BackgroundTransparency = 1
		empty.Size = UDim2.new(1, -8, 0, 18)
		empty.Font = Enum.Font.Gotham
		empty.Text = "Save a property with the star button to keep it here."
		empty.TextColor3 = Color3.fromRGB(145, 156, 171)
		empty.TextSize = 12
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.Parent = selectionPropertyFavoriteRow
		return
	end

	selectionPropertyFavoritesStatusLabel.Text = string.format("Pinned properties (%d)", #propertyFavorites)

	local currentPropertyName = trim(selectionPropertyNameBox and selectionPropertyNameBox.Text or "")

	for _, propertyName in ipairs(propertyFavorites) do
		local button = makePillButton(selectionPropertyFavoriteRow, "★ " .. propertyName, function()
			if selectionPropertyNameBox then
				selectionPropertyNameBox.Text = propertyName
			end
			refreshPropertyEditorState()
		end, currentPropertyName ~= "" and normalizeNameKey(currentPropertyName) == normalizeNameKey(propertyName), true)

		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Text = "★ " .. propertyName
	end
end

local function toggleCurrentPropertyFavorite()
	local propertyName = trim(selectionPropertyNameBox and selectionPropertyNameBox.Text or "")
	if propertyName == "" then
		if selectionPropertyOutcomeLabel then
			selectionPropertyOutcomeLabel.Text = "Pick a property name before saving a favorite."
			selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(244, 104, 104)
		end
		return
	end

	setPropertyFavorite(propertyName, not isFavoriteProperty(propertyName))
	renderPropertyFavorites()
	if selectionPropertyOutcomeLabel then
		if isFavoriteProperty(propertyName) then
			selectionPropertyOutcomeLabel.Text = string.format("Saved %s as a favorite.", propertyName)
			selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(124, 247, 212)
		else
			selectionPropertyOutcomeLabel.Text = string.format("Removed %s from favorites.", propertyName)
			selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
		end
	end
end

local function rememberPropertyHistory(path, propertyName, value)
	if type(propertyName) ~= "string" or propertyName == "" then
		return
	end

	local entry = {
		path = path or "",
		property = propertyName,
		value = value,
		valueText = formatPropertyValue(value),
		updatedAt = nowIso(),
	}

	local key = propertyHistoryKey(entry.path, entry.property)
	propertyHistoryByKey[key] = entry
	table.insert(propertyHistory, 1, entry)

	while #propertyHistory > PROPERTY_HISTORY_LIMIT do
		local removed = table.remove(propertyHistory)
		if removed then
			local removedKey = propertyHistoryKey(removed.path, removed.property)
			if propertyHistoryByKey[removedKey] == removed then
				propertyHistoryByKey[removedKey] = nil
			end
		end
	end

	savePluginState(PROPERTY_STATE_KEY, propertyHistory)
end

local function readLocalPropertyHistory()
	return propertyHistory
end

local function readPropertyValue(target, propertyName)
	if not target or type(propertyName) ~= "string" or propertyName == "" then
		return nil, false
	end

	local ok, value = pcall(function()
		return target[propertyName]
	end)
	if not ok then
		return nil, false
	end
	return value, true
end

local function valueTypeName(value)
	if value == nil then
		return "nil"
	end
	return typeof(value)
end

formatPropertyValue = function(value)
	if value == nil then
		return "nil"
	end
	local kind = typeof(value)
	if kind == "string" then
		return value
	end
	if kind == "number" or kind == "boolean" then
		return tostring(value)
	end
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(value)
	end)
	if ok then
		return encoded
	end
	return tostring(value)
end

local function parsePropertyValue(text)
	local cleaned = trim(text or "")
	if cleaned == "" then
		return ""
	end

	if cleaned == "nil" then
		return nil
	end
	if cleaned == "true" then
		return true
	end
	if cleaned == "false" then
		return false
	end

	local numberValue = tonumber(cleaned)
	if numberValue ~= nil then
		return numberValue
	end

	local first = cleaned:sub(1, 1)
	if first == "{" or first == "[" or first == "\"" then
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(cleaned)
		end)
		if ok then
			return decoded
		end
	end

	return cleaned
end

local function parseBooleanText(text)
	local cleaned = string.lower(trim(text or ""))
	if cleaned == "true" then
		return true
	end
	if cleaned == "false" then
		return false
	end
	return nil
end

local function parseVectorText(text, count)
	local parts = {}
	for token in string.gmatch(text or "", "[^,%s]+") do
		local numberValue = tonumber(token)
		if numberValue == nil then
			return nil
		end
		table.insert(parts, numberValue)
	end
	if #parts ~= count then
		return nil
	end
	return parts
end

local function parseColor3Text(text)
	local parts = parseVectorText(text, 3)
	if not parts then
		return nil
	end
	return Color3.new(parts[1], parts[2], parts[3])
end

local function parseNumberSequenceText(text)
	local parts = parseVectorText(text, 4)
	if not parts then
		return nil
	end
	return NumberSequence.new(parts[1], parts[2], parts[3], parts[4])
end

local function parseCommonTypedValue(text, referenceValue)
	local kind = typeof(referenceValue)
	local trimmed = trim(text or "")

	if kind == "boolean" then
		return parseBooleanText(trimmed)
	elseif kind == "number" then
		return tonumber(trimmed)
	elseif kind == "string" then
		return text or ""
	elseif kind == "Color3" then
		return parseColor3Text(trimmed)
	elseif kind == "Vector2" then
		local parts = parseVectorText(trimmed, 2)
		if parts then
			return Vector2.new(parts[1], parts[2])
		end
	elseif kind == "Vector3" then
		local parts = parseVectorText(trimmed, 3)
		if parts then
			return Vector3.new(parts[1], parts[2], parts[3])
		end
	elseif kind == "UDim2" then
		local parts = parseVectorText(trimmed, 4)
		if parts then
			return UDim2.new(parts[1], parts[2], parts[3], parts[4])
		end
	elseif kind == "CFrame" then
		local parts = parseVectorText(trimmed, 6)
		if parts then
			return CFrame.new(parts[1], parts[2], parts[3], parts[4], parts[5], parts[6])
		end
	elseif kind == "BrickColor" then
		local ok, value = pcall(function()
			return BrickColor.new(trimmed)
		end)
		if ok then
			return value
		end
	elseif kind == "EnumItem" then
		local enumType = tostring(referenceValue.EnumType or "")
		local ok, value = pcall(function()
			return Enum[enumType][trimmed]
		end)
		if ok and value then
			return value
		end
	end

	return nil
end

local function getPropertyTypeHint(value)
	local kind = valueTypeName(value)
	if kind == "nil" then
		return "Type: unknown"
	end
	if kind == "boolean" then
		return "Type: boolean. Use true or false."
	end
	if kind == "number" then
		return "Type: number. Use 12, 0.5, or -3."
	end
	if kind == "string" then
		return "Type: string. Plain text is fine."
	end
	if kind == "Color3" then
		return "Type: Color3. Use JSON like [1,0,0] or a color string."
	end
	if kind == "UDim2" then
		return "Type: UDim2. Use JSON or the current value as a template."
	end
	if kind == "Vector3" or kind == "Vector2" or kind == "CFrame" or kind == "BrickColor" or kind == "EnumItem" then
		return "Type: " .. kind .. ". Use the current value as a template."
	end
	return "Type: " .. kind .. ". Use JSON or plain text when appropriate."
end

local function loadPropertyState()
	local loadedHistory = loadPluginState(PROPERTY_STATE_KEY, {})
	if type(loadedHistory) == "table" then
		propertyHistory = loadedHistory
		for _, entry in ipairs(propertyHistory) do
			entry.valueText = entry.valueText or formatPropertyValue(entry.value)
			entry.updatedAt = entry.updatedAt or nowIso()
			propertyHistoryByKey[propertyHistoryKey(entry.path, entry.property)] = entry
		end
	end
end

local function loadEditorState()
	local state = loadPluginState(PROPERTY_EDITOR_STATE_KEY, {})
	if type(state) ~= "table" then
		state = {}
	end

	if selectionPropertyNameBox and type(state.propertyName) == "string" then
		selectionPropertyNameBox.Text = state.propertyName
	end
	if selectionPropertyValueBox and type(state.propertyValue) == "string" then
		selectionPropertyValueBox.Text = state.propertyValue
	end
end

local function persistEditorState()
	savePluginState(PROPERTY_EDITOR_STATE_KEY, {
		propertyName = selectionPropertyNameBox and selectionPropertyNameBox.Text or "",
		propertyValue = selectionPropertyValueBox and selectionPropertyValueBox.Text or "",
	})
end

local function applySelectedPropertyValueFromCurrent(target, propertyName)
	local value, ok = readPropertyValue(target, propertyName)
	if ok and selectionPropertyValueBox then
		selectionPropertyValueBox.Text = formatPropertyValue(value)
		return true, value
	end
	return false, nil
end

local function isNodeExpanded(instance, defaultValue)
	if treeExpansion[instance] == nil then
		treeExpansion[instance] = defaultValue and true or false
	end
	return treeExpansion[instance]
end

local function setNodeExpanded(instance, expanded)
	if instance then
		treeExpansion[instance] = expanded and true or false
	end
end

local function toggleNodeExpanded(instance, defaultValue)
	setNodeExpanded(instance, not isNodeExpanded(instance, defaultValue))
end

local function getPrimarySelection()
	local current = Selection:Get()
	return current and current[1] or nil, current or {}
end

local function renderTreeNode(parent, instance, depth, maxDepth, filterText, selectedInstance)
	if not instance then
		return false
	end

	local matches = nodeMatchesFilter(instance, filterText)
	local visibleChildMatches = false
	local okChildren, children = pcall(function()
		return instance:GetChildren()
	end)
	if okChildren then
		for _, child in ipairs(children) do
			if nodeOrDescendantMatchesFilter(child, filterText) then
				visibleChildMatches = true
				break
			end
		end
	end

	if not matches and not visibleChildMatches then
		return false
	end

	local row = Instance.new("Frame")
	local isSelected = selectedInstance == instance
	row.BackgroundColor3 = isSelected and Color3.fromRGB(35, 61, 58) or Color3.fromRGB(28, 34, 46)
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, 30)
	row.Parent = parent

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	local rowStroke = Instance.new("UIStroke")
	rowStroke.Color = isSelected and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(58, 72, 94)
	rowStroke.Thickness = 1
	rowStroke.Transparency = isSelected and 0.08 or 0.35
	rowStroke.Parent = row

	local rowPadding = Instance.new("UIPadding")
	rowPadding.PaddingLeft = UDim.new(0, 10 + (depth * 12))
	rowPadding.PaddingRight = UDim.new(0, 10)
	rowPadding.Parent = row

	local toggleButton = Instance.new("TextButton")
	toggleButton.BackgroundTransparency = 1
	toggleButton.Size = UDim2.new(0, 20, 1, 0)
	toggleButton.Position = UDim2.new(0, 0, 0, 0)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 12
	toggleButton.TextColor3 = isSelected and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(145, 156, 171)
	toggleButton.TextXAlignment = Enum.TextXAlignment.Center
	toggleButton.TextYAlignment = Enum.TextYAlignment.Center
	toggleButton.Parent = row

	local childCount = okChildren and #children or 0

	local hasChildren = childCount > 0 and depth < maxDepth
	local expanded = isNodeExpanded(instance, depth == 0)
	if trim(filterText or "") ~= "" and visibleChildMatches then
		expanded = true
	end

	if hasChildren then
		toggleButton.Text = expanded and "v" or ">"
		toggleButton.AutoButtonColor = true
		toggleButton.MouseButton1Click:Connect(function()
			toggleNodeExpanded(instance, depth == 0)
			refreshSelectionTree()
		end)
	else
		toggleButton.Text = "-"
		toggleButton.AutoButtonColor = false
	end

	local labelButton = Instance.new("TextButton")
	labelButton.BackgroundTransparency = 1
	labelButton.Position = UDim2.new(0, 22, 0, 0)
	labelButton.Size = UDim2.new(1, -126, 1, 0)
	labelButton.Font = Enum.Font.Gotham
	labelButton.Text = string.format("%s [%s]", instance.Name, instance.ClassName)
	labelButton.TextColor3 = isSelected and Color3.fromRGB(232, 238, 247) or Color3.fromRGB(240, 244, 248)
	labelButton.TextSize = 12
	labelButton.TextXAlignment = Enum.TextXAlignment.Left
	labelButton.TextYAlignment = Enum.TextYAlignment.Center
	labelButton.TextTruncate = Enum.TextTruncate.AtEnd
	labelButton.AutoButtonColor = true
	labelButton.Parent = row

	labelButton.MouseButton1Click:Connect(function()
		selectInstance(instance)
	end)

	local classBadge = Instance.new("TextLabel")
	classBadge.BackgroundColor3 = isSelected and Color3.fromRGB(21, 42, 40) or Color3.fromRGB(20, 25, 34)
	classBadge.BorderSizePixel = 0
	classBadge.AnchorPoint = Vector2.new(1, 0.5)
	classBadge.Position = UDim2.new(1, -2, 0.5, 0)
	classBadge.Size = UDim2.new(0, 96, 0, 20)
	classBadge.Font = Enum.Font.GothamSemibold
	classBadge.Text = instance.ClassName
	classBadge.TextColor3 = isSelected and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(145, 156, 171)
	classBadge.TextSize = 11
	classBadge.TextTruncate = Enum.TextTruncate.AtEnd
	classBadge.TextXAlignment = Enum.TextXAlignment.Center
	classBadge.Parent = row

	local classBadgeCorner = Instance.new("UICorner")
	classBadgeCorner.CornerRadius = UDim.new(0, 999)
	classBadgeCorner.Parent = classBadge

	local classBadgeStroke = Instance.new("UIStroke")
	classBadgeStroke.Color = isSelected and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(58, 72, 94)
	classBadgeStroke.Thickness = 1
	classBadgeStroke.Transparency = isSelected and 0.15 or 0.5
	classBadgeStroke.Parent = classBadge

	if hasChildren and expanded then
		for _, child in ipairs(children) do
			renderTreeNode(parent, child, depth + 1, maxDepth, filterText, selectedInstance)
		end
	end

	return true
end

local function refreshPropertyEditor()
	local target = getPrimarySelection()
	if not selectionPropertyStatusLabel then
		return
	end

	if not target then
		selectionPropertyStatusLabel.Text = "Pick a property name to read or edit."
		if selectionPropertyValueBox then
			selectionPropertyValueBox.Text = ""
		end
		return
	end

	local propertyName = trim(selectionPropertyNameBox and selectionPropertyNameBox.Text or "")
	if propertyName == "" then
		selectionPropertyStatusLabel.Text = "Enter a property name, then load or apply it."
		if selectionPropertyTypeLabel then
			selectionPropertyTypeLabel.Text = "Type: unknown"
		end
		if selectionPropertyValueBox then
			selectionPropertyValueBox.Text = ""
		end
		return
	end

	local value, ok = readPropertyValue(target, propertyName)
	if ok then
		selectionPropertyStatusLabel.Text = string.format("Loaded %s from %s.", propertyName, target.Name)
		if selectionPropertyTypeLabel then
			selectionPropertyTypeLabel.Text = getPropertyTypeHint(value)
		end
		if selectionPropertyValueBox then
			selectionPropertyValueBox.Text = formatPropertyValue(value)
		end
	else
		selectionPropertyStatusLabel.Text = string.format("Could not read %s on %s.", propertyName, target.Name)
		if selectionPropertyTypeLabel then
			selectionPropertyTypeLabel.Text = "Type: unknown. Load a valid property to infer it."
		end
	end
end

local function refreshPropertyHistory()
	if not selectionPropertyHistoryList or not selectionPropertyHistoryStatusLabel then
		return
	end

	clearGuiRows(selectionPropertyHistoryList)

	if #propertyHistory == 0 then
		selectionPropertyHistoryStatusLabel.Text = "No local property history yet."
		local empty = Instance.new("TextLabel")
		empty.BackgroundTransparency = 1
		empty.Size = UDim2.new(1, -8, 0, 18)
		empty.Font = Enum.Font.Gotham
		empty.Text = "Edits you apply will appear here."
		empty.TextColor3 = Color3.fromRGB(145, 156, 171)
		empty.TextSize = 12
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.Parent = selectionPropertyHistoryList
		return
	end

	selectionPropertyHistoryStatusLabel.Text = string.format("Local history: %d recent edits.", #propertyHistory)

	for index, entry in ipairs(propertyHistory) do
		local row = Instance.new("Frame")
		row.BackgroundColor3 = Color3.fromRGB(28, 34, 46)
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, -2, 0, 44)
		row.Parent = selectionPropertyHistoryList

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row

		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.Position = UDim2.new(0, 10, 0, 5)
		text.Size = UDim2.new(1, -95, 0, 16)
		text.Font = Enum.Font.GothamSemibold
		text.Text = string.format("%s = %s", entry.property, entry.valueText or formatPropertyValue(entry.value))
		text.TextColor3 = Color3.fromRGB(240, 244, 248)
		text.TextSize = 12
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.Parent = row

		local meta = Instance.new("TextLabel")
		meta.BackgroundTransparency = 1
		meta.Position = UDim2.new(0, 10, 0, 22)
		meta.Size = UDim2.new(1, -95, 0, 14)
		meta.Font = Enum.Font.Gotham
		meta.Text = string.format("%s%s", entry.path ~= "" and (entry.path .. "  ") or "", entry.updatedAt or nowIso())
		meta.TextColor3 = Color3.fromRGB(145, 156, 171)
		meta.TextSize = 10
		meta.TextXAlignment = Enum.TextXAlignment.Left
		meta.Parent = row

		local recall = makeButton(row, "Recall", function()
			if selectionPropertyNameBox then
				selectionPropertyNameBox.Text = entry.property
			end
			if selectionPropertyValueBox then
				selectionPropertyValueBox.Text = entry.valueText
			end
			selectionPropertyStatusLabel.Text = string.format("Recalled %s from history.", entry.property)
		end)
		recall.Position = UDim2.new(1, -78, 0, 7)
		recall.Size = UDim2.new(0, 66, 0, 28)
		recall.AutomaticSize = Enum.AutomaticSize.None
	end
end

local function renderPropertyQuickReads()
	if not selectionPropertyQuickRow then
		return
	end

	clearGuiRows(selectionPropertyQuickRow)

	for _, propertyName in ipairs(QUICK_READ_PROPERTIES) do
		makeButton(selectionPropertyQuickRow, propertyName, function()
			if selectionPropertyNameBox then
				selectionPropertyNameBox.Text = propertyName
			end
			refreshPropertyEditor()
		end)
	end
end

local function refreshPropertyEditorState()
	syncPropertyAssist()
	persistEditorState()
end

local function syncPropertyAssist()
	local target = getPrimarySelection()
	local propertyName = trim(selectionPropertyNameBox and selectionPropertyNameBox.Text or "")

	if not target or propertyName == "" then
		if selectionPropertyTypeLabel then
			selectionPropertyTypeLabel.Text = "Type: unknown"
		end
		return
	end

	local reference, ok = readPropertyValue(target, propertyName)
	if selectionPropertyTypeLabel then
		selectionPropertyTypeLabel.Text = getPropertyTypeHint(reference)
	end

	local loaded = false
	if ok and selectionPropertyValueBox then
		if trim(selectionPropertyValueBox.Text or "") == "" or selectionPropertyValueBox.Text == formatPropertyValue(reference) then
			selectionPropertyValueBox.Text = formatPropertyValue(reference)
			loaded = true
		end
	end

	if loaded then
		selectionPropertyStatusLabel.Text = string.format("Loaded %s from %s.", propertyName, target.Name)
	end
end

local function refreshSelectionEditor()
	local target, selection = getPrimarySelection()
	local count = #selection

	if selectionSummaryLabel then
		if count == 0 then
			selectionSummaryLabel.Text = "Nothing selected."
		elseif count == 1 then
			selectionSummaryLabel.Text = "1 item selected."
		else
			selectionSummaryLabel.Text = string.format("%d items selected.", count)
		end
	end

	if selectionStatusLabel then
		if target then
			selectionStatusLabel.Text = target:GetFullName()
		else
			selectionStatusLabel.Text = "Select an instance to edit attributes and tags."
		end
	end

	if not target then
		if selectionTargetLabel then
			selectionTargetLabel.Text = "Path: none"
		end
		if selectionAttributesBox then
			selectionAttributesBox.Text = "{}"
		end
		if selectionTagsBox then
			selectionTagsBox.Text = ""
		end
		return
	end

	if selectionTargetLabel then
		selectionTargetLabel.Text = "Path: " .. target:GetFullName() .. "  [" .. target.ClassName .. "]"
	end
	refreshPropertyEditor()
	if selectionAttributesBox then
		selectionAttributesBox.Text = encodeJsonSafe(readAttributes(target))
	end
	if selectionTagsBox then
		selectionTagsBox.Text = formatTagsText(readTags(target))
	end
end

function refreshSelectionTree()
	if not selectionList then
		return
	end

	clearGuiRows(selectionList)

	local target, selection = getPrimarySelection()
	local filterText = getFilterText()
	if selectionTreeFilterStatusLabel then
		if filterText == "" then
			selectionTreeFilterStatusLabel.Text = "Showing all nodes."
		else
			selectionTreeFilterStatusLabel.Text = string.format("Filter: %s", filterText)
		end
	end

	if #selection == 0 then
		local empty = Instance.new("TextLabel")
		empty.BackgroundTransparency = 1
		empty.Size = UDim2.new(1, -8, 0, 20)
		empty.Font = Enum.Font.Gotham
		empty.Text = "No selection."
		empty.TextColor3 = Color3.fromRGB(145, 156, 171)
		empty.TextSize = 12
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.Parent = selectionList
		return
	end

	for _, rootInstance in ipairs(selection) do
		renderTreeNode(selectionList, rootInstance, 0, 20, filterText, target)
	end

	if target and selectionStatusLabel then
		selectionStatusLabel.Text = target:GetFullName()
	end
end

local function refreshSelectionView()
	refreshSelectionTree()
	refreshSelectionEditor()
end

local function applySelectionData()
	local target = getPrimarySelection()
	if not target then
		messageLabel.Text = "Select an instance before applying data."
		return
	end

	local ok, attributes = pcall(function()
		return parseAttributesText(selectionAttributesBox and selectionAttributesBox.Text or "{}")
	end)
	if not ok then
		messageLabel.Text = tostring(attributes)
		if selectionPropertyOutcomeLabel then
			selectionPropertyOutcomeLabel.Text = tostring(attributes)
			selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(244, 104, 104)
		end
		return
	end

	local tags = parseTagsText(selectionTagsBox and selectionTagsBox.Text or "")
	if selectionPropertyOutcomeLabel then
		selectionPropertyOutcomeLabel.Text = "Queued batch update."
		selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(124, 247, 212)
	end
	queuePanelJob("set_properties", {
		path = target:GetFullName(),
		properties = {},
		attributes = attributes,
		tags = tags,
	})
	messageLabel.Text = string.format("Queued batch update for %s.", target.Name)
end

local function applySelectedProperty()
	local target = getPrimarySelection()
	if not target then
		messageLabel.Text = "Select an instance before applying a property."
		return
	end

	local propertyName = trim(selectionPropertyNameBox and selectionPropertyNameBox.Text or "")
	if propertyName == "" then
		messageLabel.Text = "Enter a property name first."
		if selectionPropertyOutcomeLabel then
			selectionPropertyOutcomeLabel.Text = "Property name is required."
			selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(244, 104, 104)
		end
		return
	end

	local referenceValue = nil
	if target and propertyName ~= "" then
		local currentValue, hasCurrent = readPropertyValue(target, propertyName)
		if hasCurrent then
			referenceValue = currentValue
		end
	end

	local typedValue = parseCommonTypedValue(selectionPropertyValueBox and selectionPropertyValueBox.Text or "", referenceValue)
	if typedValue == nil then
		local ok, parsed = pcall(function()
			return parsePropertyValue(selectionPropertyValueBox and selectionPropertyValueBox.Text or "")
		end)
		if not ok then
			messageLabel.Text = tostring(parsed)
			if selectionPropertyOutcomeLabel then
				selectionPropertyOutcomeLabel.Text = tostring(parsed)
				selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(244, 104, 104)
			end
			return
		end
		typedValue = parsed
	end

	if typedValue == nil then
		messageLabel.Text = "Could not infer a value for that property."
		if selectionPropertyOutcomeLabel then
			selectionPropertyOutcomeLabel.Text = "Could not infer a value for that property."
			selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(244, 104, 104)
		end
		return
	end

	if selectionPropertyOutcomeLabel then
		selectionPropertyOutcomeLabel.Text = string.format("Queued property update for %s.", propertyName)
		selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(124, 247, 212)
	end
	queuePanelJob("set_property", {
		path = target:GetFullName(),
		property = propertyName,
		value = typedValue,
	})
	rememberPropertyHistory(target:GetFullName(), propertyName, typedValue)
	refreshPropertyHistory()
	messageLabel.Text = string.format("Queued property update for %s.", propertyName)
end

local function createTree(parent, node)
	local className = node and node.className or "Folder"
	local instance = Instance.new(className)
	instance.Name = (node and node.name) or className
	instance.Parent = parent
	setProperties(instance, node and node.properties or {})
	setAttributes(instance, node and node.attributes or {})
	setTags(instance, node and node.tags or {})

	for _, child in ipairs(node and node.children or {}) do
		createTree(instance, child)
	end

	return instance
end

local function executeJob(job)
	local ok, result = pcall(function()
		if job.type == "ping" then
			return {
				ok = true,
				message = "pong from Studio",
				selection = serializeSelection(),
			}
		elseif job.type == "inspect_selection" then
			return {
				ok = true,
				selection = serializeSelection(),
			}
		elseif job.type == "get_properties" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			return {
				ok = true,
				path = target:GetFullName(),
				className = target.ClassName,
				name = target.Name,
				properties = readProperties(target, job.payload and job.payload.properties or {}),
			}
		elseif job.type == "get_attributes" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			return {
				ok = true,
				path = target:GetFullName(),
				attributes = readAttributes(target),
			}
		elseif job.type == "set_attributes" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			setAttributes(target, job.payload and job.payload.attributes or {})
			ChangeHistoryService:SetWaypoint("iLuau set attributes")
			return {
				ok = true,
				path = target:GetFullName(),
				attributes = job.payload and job.payload.attributes or {},
			}
		elseif job.type == "get_tags" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			return {
				ok = true,
				path = target:GetFullName(),
				tags = readTags(target),
			}
		elseif job.type == "set_tags" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			setTags(target, job.payload and job.payload.tags or {})
			ChangeHistoryService:SetWaypoint("iLuau set tags")
			return {
				ok = true,
				path = target:GetFullName(),
				tags = job.payload and job.payload.tags or {},
			}
		elseif job.type == "set_property" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			pcall(function()
				target[job.payload.property] = job.payload.value
			end)
			ChangeHistoryService:SetWaypoint("iLuau set property")
			return {
				ok = true,
				path = target:GetFullName(),
				property = job.payload.property,
			}
		elseif job.type == "set_properties" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			setProperties(target, job.payload and job.payload.properties or {})
			setAttributes(target, job.payload and job.payload.attributes or {})
			setTags(target, job.payload and job.payload.tags or {})
			ChangeHistoryService:SetWaypoint("iLuau set properties")
			return {
				ok = true,
				path = target:GetFullName(),
				properties = job.payload and job.payload.properties or {},
				attributes = readAttributes(target),
				tags = readTags(target),
			}
		elseif job.type == "create_instance" then
			local className = job.payload and job.payload.className or "Folder"
			local parent = findByPath(job.payload and job.payload.parentPath or "game.Workspace") or game.Workspace
			local instance = createTree(parent, {
				className = className,
				name = (job.payload and job.payload.name) or className,
				properties = job.payload and job.payload.properties or {},
				attributes = job.payload and job.payload.attributes or {},
				tags = job.payload and job.payload.tags or {},
				children = job.payload and job.payload.children or {},
			})
			ChangeHistoryService:SetWaypoint("iLuau create instance")
			return {
				ok = true,
				path = instance:GetFullName(),
				className = instance.ClassName,
				children = #((job.payload and job.payload.children) or {}),
			}
		elseif job.type == "delete_instance" then
			local target = findByPath(job.payload and job.payload.path or "")
			if not target then
				error("target not found")
			end
			target:Destroy()
			ChangeHistoryService:SetWaypoint("iLuau delete instance")
			return { ok = true }
		elseif job.type == "sync_snapshot" then
			return {
				ok = true,
				selection = serializeSelection(),
				placeName = game.Name,
				placeId = game.PlaceId,
			}
		else
			error("unsupported job type: " .. tostring(job.type))
		end
	end)

	if ok then
		return true, result
	end

	return false, result
end

local function heartbeat()
	local response = safeRequest("POST", "/api/bridge/heartbeat", {
		clientId = CLIENT_ID,
		clientName = CLIENT_NAME,
		placeId = game.PlaceId,
		placeName = game.Name,
	})
	return response and response.Success
end

local headerCard = makeCard(90)
headerCard.LayoutOrder = 1
headerCard.Parent = body
makeSectionTitle(headerCard, "Connection")

local serverValue = makeStat(headerCard, "Server", "offline", 30)
local bridgeValue = makeStat(headerCard, "Bridge", "offline", 48)

local selectionCard = makeCard(320)
selectionCard.LayoutOrder = 2
selectionCard.Parent = body
makeSectionTitle(selectionCard, "Selection tree")

selectionSummaryLabel = Instance.new("TextLabel")
selectionSummaryLabel.BackgroundTransparency = 1
selectionSummaryLabel.Position = UDim2.new(0, 10, 0, 28)
selectionSummaryLabel.Size = UDim2.new(1, -20, 0, 16)
selectionSummaryLabel.Font = Enum.Font.Gotham
selectionSummaryLabel.Text = "Nothing selected."
selectionSummaryLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
selectionSummaryLabel.TextSize = 12
selectionSummaryLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionSummaryLabel.Parent = selectionCard

selectionTreeFilterStatusLabel = Instance.new("TextLabel")
selectionTreeFilterStatusLabel.BackgroundTransparency = 1
selectionTreeFilterStatusLabel.Position = UDim2.new(0, 10, 0, 44)
selectionTreeFilterStatusLabel.Size = UDim2.new(1, -20, 0, 16)
selectionTreeFilterStatusLabel.Font = Enum.Font.GothamSemibold
selectionTreeFilterStatusLabel.Text = "Showing all nodes."
selectionTreeFilterStatusLabel.TextColor3 = Color3.fromRGB(124, 247, 212)
selectionTreeFilterStatusLabel.TextSize = 12
selectionTreeFilterStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionTreeFilterStatusLabel.Parent = selectionCard

local treeFilterLabel = Instance.new("TextLabel")
treeFilterLabel.BackgroundTransparency = 1
treeFilterLabel.Position = UDim2.new(0, 10, 0, 66)
treeFilterLabel.Size = UDim2.new(1, -20, 0, 16)
treeFilterLabel.Font = Enum.Font.GothamSemibold
treeFilterLabel.Text = "Tree filter"
treeFilterLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
treeFilterLabel.TextSize = 12
treeFilterLabel.TextXAlignment = Enum.TextXAlignment.Left
treeFilterLabel.Parent = selectionCard

selectionTreeFilterBox = makeTextBox(selectionCard, "Filter by name, class, or path", 28)
selectionTreeFilterBox.Position = UDim2.new(0, 10, 0, 84)
selectionTreeFilterBox.Size = UDim2.new(1, -20, 0, 30)

selectionTreeActionsRow = Instance.new("Frame")
selectionTreeActionsRow.BackgroundTransparency = 1
selectionTreeActionsRow.Position = UDim2.new(0, 10, 0, 118)
selectionTreeActionsRow.Size = UDim2.new(1, -20, 0, 30)
selectionTreeActionsRow.Parent = selectionCard

local treeActionsLayout = Instance.new("UIListLayout")
treeActionsLayout.FillDirection = Enum.FillDirection.Horizontal
treeActionsLayout.Padding = UDim.new(0, 8)
treeActionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
treeActionsLayout.Parent = selectionTreeActionsRow

makePillButton(selectionTreeActionsRow, "Expand all", function()
	setTreeExpansionForSelection(true)
	refreshSelectionTree()
end, false, true)

makePillButton(selectionTreeActionsRow, "Collapse all", function()
	setTreeExpansionForSelection(false)
	refreshSelectionTree()
end, false, true)

makePillButton(selectionTreeActionsRow, "Clear filter", function()
	if selectionTreeFilterBox then
		selectionTreeFilterBox.Text = ""
	end
	applyTreeFilter("")
end, false, true)

selectionList = Instance.new("ScrollingFrame")
selectionList.BackgroundTransparency = 1
selectionList.BorderSizePixel = 0
selectionList.Position = UDim2.new(0, 10, 0, 154)
selectionList.Size = UDim2.new(1, -20, 1, -164)
selectionList.CanvasSize = UDim2.new(0, 0, 0, 0)
selectionList.ScrollBarThickness = 6
selectionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
selectionList.Parent = selectionCard

local selectionLayout = Instance.new("UIListLayout")
selectionLayout.Padding = UDim.new(0, 6)
selectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
selectionLayout.Parent = selectionList

local propertiesCard = makeCard(468)
propertiesCard.LayoutOrder = 3
propertiesCard.Parent = body
makeSectionTitle(propertiesCard, "Properties")

selectionPropertyStatusLabel = Instance.new("TextLabel")
selectionPropertyStatusLabel.BackgroundTransparency = 1
selectionPropertyStatusLabel.Position = UDim2.new(0, 10, 0, 28)
selectionPropertyStatusLabel.Size = UDim2.new(1, -20, 0, 16)
selectionPropertyStatusLabel.Font = Enum.Font.Gotham
selectionPropertyStatusLabel.Text = "Pick a property name to read or edit."
selectionPropertyStatusLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
selectionPropertyStatusLabel.TextSize = 12
selectionPropertyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionPropertyStatusLabel.Parent = propertiesCard

selectionPropertyTypeLabel = Instance.new("TextLabel")
selectionPropertyTypeLabel.BackgroundTransparency = 1
selectionPropertyTypeLabel.Position = UDim2.new(0, 10, 0, 44)
selectionPropertyTypeLabel.Size = UDim2.new(1, -20, 0, 16)
selectionPropertyTypeLabel.Font = Enum.Font.GothamSemibold
selectionPropertyTypeLabel.Text = "Type: unknown"
selectionPropertyTypeLabel.TextColor3 = Color3.fromRGB(124, 247, 212)
selectionPropertyTypeLabel.TextSize = 12
selectionPropertyTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionPropertyTypeLabel.Parent = propertiesCard

local propertyNameLabel = Instance.new("TextLabel")
propertyNameLabel.BackgroundTransparency = 1
propertyNameLabel.Position = UDim2.new(0, 10, 0, 64)
propertyNameLabel.Size = UDim2.new(1, -20, 0, 16)
propertyNameLabel.Font = Enum.Font.GothamSemibold
propertyNameLabel.Text = "Property name"
propertyNameLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
propertyNameLabel.TextSize = 12
propertyNameLabel.TextXAlignment = Enum.TextXAlignment.Left
propertyNameLabel.Parent = propertiesCard

selectionPropertyNameBox = makeTextBox(propertiesCard, "Transparency", 28)
selectionPropertyNameBox.Size = UDim2.new(1, -20, 0, 30)

local propertyValueLabel = Instance.new("TextLabel")
propertyValueLabel.BackgroundTransparency = 1
propertyValueLabel.Position = UDim2.new(0, 10, 0, 106)
propertyValueLabel.Size = UDim2.new(1, -20, 0, 16)
propertyValueLabel.Font = Enum.Font.GothamSemibold
propertyValueLabel.Text = "Property value"
propertyValueLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
propertyValueLabel.TextSize = 12
propertyValueLabel.TextXAlignment = Enum.TextXAlignment.Left
propertyValueLabel.Parent = propertiesCard

selectionPropertyValueBox = makeTextBox(propertiesCard, "0.5, true, \"text\", or JSON", 36)
selectionPropertyValueBox.Size = UDim2.new(1, -20, 0, 40)

local propertyButtonRow = Instance.new("Frame")
propertyButtonRow.BackgroundTransparency = 1
propertyButtonRow.Position = UDim2.new(0, 10, 0, 158)
propertyButtonRow.Size = UDim2.new(1, -20, 0, 30)
propertyButtonRow.Parent = propertiesCard

local propertyButtonLayout = Instance.new("UIListLayout")
propertyButtonLayout.FillDirection = Enum.FillDirection.Horizontal
propertyButtonLayout.Padding = UDim.new(0, 8)
propertyButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
propertyButtonLayout.Parent = propertyButtonRow

makeButton(propertyButtonRow, "Load", function()
	refreshPropertyEditor()
end)

makeButton(propertyButtonRow, "Apply property", function()
	applySelectedProperty()
end)

makeButton(propertyButtonRow, "☆ Favorite", function()
	toggleCurrentPropertyFavorite()
end)

selectionPropertyOutcomeLabel = Instance.new("TextLabel")
selectionPropertyOutcomeLabel.BackgroundTransparency = 1
selectionPropertyOutcomeLabel.Position = UDim2.new(0, 10, 0, 190)
selectionPropertyOutcomeLabel.Size = UDim2.new(1, -20, 0, 16)
selectionPropertyOutcomeLabel.Font = Enum.Font.Gotham
selectionPropertyOutcomeLabel.Text = "Ready."
selectionPropertyOutcomeLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
selectionPropertyOutcomeLabel.TextSize = 12
selectionPropertyOutcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionPropertyOutcomeLabel.Parent = propertiesCard

selectionPropertyFavoritesStatusLabel = Instance.new("TextLabel")
selectionPropertyFavoritesStatusLabel.BackgroundTransparency = 1
selectionPropertyFavoritesStatusLabel.Position = UDim2.new(0, 10, 0, 214)
selectionPropertyFavoritesStatusLabel.Size = UDim2.new(1, -20, 0, 16)
selectionPropertyFavoritesStatusLabel.Font = Enum.Font.GothamSemibold
selectionPropertyFavoritesStatusLabel.Text = "Favorites"
selectionPropertyFavoritesStatusLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
selectionPropertyFavoritesStatusLabel.TextSize = 12
selectionPropertyFavoritesStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionPropertyFavoritesStatusLabel.Parent = propertiesCard

local favoritesHintLabel = Instance.new("TextLabel")
favoritesHintLabel.BackgroundTransparency = 1
favoritesHintLabel.Position = UDim2.new(0, 10, 0, 198)
favoritesHintLabel.Size = UDim2.new(1, -20, 0, 14)
favoritesHintLabel.Font = Enum.Font.Gotham
favoritesHintLabel.Text = "Click a favorite to load it into the editor."
favoritesHintLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
favoritesHintLabel.TextSize = 11
favoritesHintLabel.TextXAlignment = Enum.TextXAlignment.Left
favoritesHintLabel.Parent = propertiesCard

selectionPropertyFavoriteRow = Instance.new("ScrollingFrame")
selectionPropertyFavoriteRow.BackgroundTransparency = 1
selectionPropertyFavoriteRow.BorderSizePixel = 0
selectionPropertyFavoriteRow.Position = UDim2.new(0, 10, 0, 232)
selectionPropertyFavoriteRow.Size = UDim2.new(1, -20, 0, 38)
selectionPropertyFavoriteRow.CanvasSize = UDim2.new(0, 0, 0, 0)
selectionPropertyFavoriteRow.ScrollBarThickness = 0
selectionPropertyFavoriteRow.ScrollingDirection = Enum.ScrollingDirection.X
selectionPropertyFavoriteRow.AutomaticCanvasSize = Enum.AutomaticSize.X
selectionPropertyFavoriteRow.Parent = propertiesCard

local favoriteLayout = Instance.new("UIListLayout")
favoriteLayout.FillDirection = Enum.FillDirection.Horizontal
favoriteLayout.Padding = UDim.new(0, 8)
favoriteLayout.SortOrder = Enum.SortOrder.LayoutOrder
favoriteLayout.Parent = selectionPropertyFavoriteRow

local quickReadLabel = Instance.new("TextLabel")
quickReadLabel.BackgroundTransparency = 1
quickReadLabel.Position = UDim2.new(0, 10, 0, 274)
quickReadLabel.Size = UDim2.new(1, -20, 0, 16)
quickReadLabel.Font = Enum.Font.GothamSemibold
quickReadLabel.Text = "Quick read"
quickReadLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
quickReadLabel.TextSize = 12
quickReadLabel.TextXAlignment = Enum.TextXAlignment.Left
quickReadLabel.Parent = propertiesCard

selectionPropertyQuickRow = Instance.new("ScrollingFrame")
selectionPropertyQuickRow.BackgroundTransparency = 1
selectionPropertyQuickRow.BorderSizePixel = 0
selectionPropertyQuickRow.Position = UDim2.new(0, 10, 0, 292)
selectionPropertyQuickRow.Size = UDim2.new(1, -20, 0, 40)
selectionPropertyQuickRow.CanvasSize = UDim2.new(0, 0, 0, 0)
selectionPropertyQuickRow.ScrollBarThickness = 0
selectionPropertyQuickRow.ScrollingDirection = Enum.ScrollingDirection.X
selectionPropertyQuickRow.AutomaticCanvasSize = Enum.AutomaticSize.X
selectionPropertyQuickRow.Parent = propertiesCard

local quickReadLayout = Instance.new("UIListLayout")
quickReadLayout.FillDirection = Enum.FillDirection.Horizontal
quickReadLayout.Padding = UDim.new(0, 8)
quickReadLayout.SortOrder = Enum.SortOrder.LayoutOrder
quickReadLayout.Parent = selectionPropertyQuickRow

selectionPropertyHistoryStatusLabel = Instance.new("TextLabel")
selectionPropertyHistoryStatusLabel.BackgroundTransparency = 1
selectionPropertyHistoryStatusLabel.Position = UDim2.new(0, 10, 0, 348)
selectionPropertyHistoryStatusLabel.Size = UDim2.new(1, -20, 0, 16)
selectionPropertyHistoryStatusLabel.Font = Enum.Font.GothamSemibold
selectionPropertyHistoryStatusLabel.Text = "Local history"
selectionPropertyHistoryStatusLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
selectionPropertyHistoryStatusLabel.TextSize = 12
selectionPropertyHistoryStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionPropertyHistoryStatusLabel.Parent = propertiesCard

selectionPropertyHistoryList = Instance.new("ScrollingFrame")
selectionPropertyHistoryList.BackgroundTransparency = 1
selectionPropertyHistoryList.BorderSizePixel = 0
selectionPropertyHistoryList.Position = UDim2.new(0, 10, 0, 370)
selectionPropertyHistoryList.Size = UDim2.new(1, -20, 0, 86)
selectionPropertyHistoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
selectionPropertyHistoryList.ScrollBarThickness = 6
selectionPropertyHistoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
selectionPropertyHistoryList.Parent = propertiesCard

local propertyHistoryLayout = Instance.new("UIListLayout")
propertyHistoryLayout.Padding = UDim.new(0, 8)
propertyHistoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
propertyHistoryLayout.Parent = selectionPropertyHistoryList

local editorCard = makeCard(250)
editorCard.LayoutOrder = 4
editorCard.Parent = body
makeSectionTitle(editorCard, "Attributes and tags")

selectionStatusLabel = Instance.new("TextLabel")
selectionStatusLabel.BackgroundTransparency = 1
selectionStatusLabel.Position = UDim2.new(0, 10, 0, 28)
selectionStatusLabel.Size = UDim2.new(1, -20, 0, 16)
selectionStatusLabel.Font = Enum.Font.Gotham
selectionStatusLabel.Text = "Select an instance to edit attributes and tags."
selectionStatusLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
selectionStatusLabel.TextSize = 12
selectionStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionStatusLabel.Parent = editorCard

selectionTargetLabel = Instance.new("TextLabel")
selectionTargetLabel.BackgroundTransparency = 1
selectionTargetLabel.Position = UDim2.new(0, 10, 0, 48)
selectionTargetLabel.Size = UDim2.new(1, -20, 0, 16)
selectionTargetLabel.Font = Enum.Font.GothamSemibold
selectionTargetLabel.Text = "Path: none"
selectionTargetLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
selectionTargetLabel.TextSize = 12
selectionTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionTargetLabel.Parent = editorCard

local attributesLabel = Instance.new("TextLabel")
attributesLabel.BackgroundTransparency = 1
attributesLabel.Position = UDim2.new(0, 10, 0, 68)
attributesLabel.Size = UDim2.new(1, -20, 0, 16)
attributesLabel.Font = Enum.Font.GothamSemibold
attributesLabel.Text = "Attributes JSON"
attributesLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
attributesLabel.TextSize = 12
attributesLabel.TextXAlignment = Enum.TextXAlignment.Left
attributesLabel.Parent = editorCard

selectionAttributesBox = makeTextBox(editorCard, '{"Health": 100}', 86)
selectionAttributesBox.Size = UDim2.new(1, -20, 0, 70)

local tagsLabel = Instance.new("TextLabel")
tagsLabel.BackgroundTransparency = 1
tagsLabel.Position = UDim2.new(0, 10, 0, 162)
tagsLabel.Size = UDim2.new(1, -20, 0, 16)
tagsLabel.Font = Enum.Font.GothamSemibold
tagsLabel.Text = "Tags"
tagsLabel.TextColor3 = Color3.fromRGB(232, 238, 247)
tagsLabel.TextSize = 12
tagsLabel.TextXAlignment = Enum.TextXAlignment.Left
tagsLabel.Parent = editorCard

selectionTagsBox = makeTextBox(editorCard, "Enemy, Interactable, UI", 180)
selectionTagsBox.Size = UDim2.new(1, -20, 0, 36)

local editorButtonRow = Instance.new("Frame")
editorButtonRow.BackgroundTransparency = 1
editorButtonRow.Position = UDim2.new(0, 10, 0, 222)
editorButtonRow.Size = UDim2.new(1, -20, 0, 34)
editorButtonRow.Parent = editorCard

local editorButtonLayout = Instance.new("UIListLayout")
editorButtonLayout.FillDirection = Enum.FillDirection.Horizontal
editorButtonLayout.Padding = UDim.new(0, 8)
editorButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
editorButtonLayout.Parent = editorButtonRow

makeButton(editorButtonRow, "Refresh target", function()
	refreshSelectionView()
end)

makeButton(editorButtonRow, "Apply batch", function()
	applySelectionData()
end)

local actionCard = makeCard(122)
actionCard.LayoutOrder = 5
actionCard.Parent = body
makeSectionTitle(actionCard, "Quick actions")

local buttonRow = Instance.new("Frame")
buttonRow.BackgroundTransparency = 1
buttonRow.Position = UDim2.new(0, 10, 0, 34)
buttonRow.Size = UDim2.new(1, -20, 0, 76)
buttonRow.Parent = actionCard

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.Padding = UDim.new(0, 8)
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.Parent = buttonRow

local messageLabel = Instance.new("TextLabel")
messageLabel.BackgroundTransparency = 1
messageLabel.Position = UDim2.new(0, 10, 0, 104)
messageLabel.Size = UDim2.new(1, -20, 0, 16)
messageLabel.Font = Enum.Font.Gotham
messageLabel.Text = "Ready."
messageLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
messageLabel.TextSize = 12
messageLabel.TextXAlignment = Enum.TextXAlignment.Left
messageLabel.Parent = actionCard

local jobCard = makeCard(286)
jobCard.LayoutOrder = 6
jobCard.Parent = body
makeSectionTitle(jobCard, "Recent jobs")

local jobList = Instance.new("ScrollingFrame")
jobList.BackgroundTransparency = 1
jobList.BorderSizePixel = 0
jobList.Position = UDim2.new(0, 10, 0, 34)
jobList.Size = UDim2.new(1, -20, 1, -44)
jobList.CanvasSize = UDim2.new(0, 0, 0, 0)
jobList.ScrollBarThickness = 6
jobList.AutomaticCanvasSize = Enum.AutomaticSize.Y
jobList.Parent = jobCard

local jobLayout = Instance.new("UIListLayout")
jobLayout.Padding = UDim.new(0, 8)
jobLayout.SortOrder = Enum.SortOrder.LayoutOrder
jobLayout.Parent = jobList

local chatCard = makeCard(320)
chatCard.LayoutOrder = 2
chatCard.Parent = body
makeSectionTitle(chatCard, "Codex chat")

local chatHistory = Instance.new("ScrollingFrame")
chatHistory.BackgroundTransparency = 1
chatHistory.BorderSizePixel = 0
chatHistory.Position = UDim2.new(0, 10, 0, 34)
chatHistory.Size = UDim2.new(1, -20, 0, 210)
chatHistory.CanvasSize = UDim2.new(0, 0, 0, 0)
chatHistory.ScrollBarThickness = 6
chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatHistory.Parent = chatCard

local chatLayout = Instance.new("UIListLayout")
chatLayout.Padding = UDim.new(0, 6)
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Parent = chatHistory

local chatInputBox = makeTextBox(chatCard, "Ask Codex... (Enter to send)", 44)
chatInputBox.Position = UDim2.new(0, 10, 0, 252)
chatInputBox.Size = UDim2.new(1, -104, 0, 44)
chatInputBox.MultiLine = true

local chatSendButton = makeButton(chatCard, "Send", function() end)
chatSendButton.AnchorPoint = Vector2.new(1, 0)
chatSendButton.AutomaticSize = Enum.AutomaticSize.None
chatSendButton.Position = UDim2.new(1, -10, 0, 252)
chatSendButton.Size = UDim2.new(0, 80, 0, 44)

local chatEmptyLabel = Instance.new("TextLabel")
chatEmptyLabel.BackgroundTransparency = 1
chatEmptyLabel.LayoutOrder = 0
chatEmptyLabel.Size = UDim2.new(1, -4, 0, 18)
chatEmptyLabel.Font = Enum.Font.Gotham
chatEmptyLabel.Text = "No messages yet. Replies arrive from Codex."
chatEmptyLabel.TextColor3 = Color3.fromRGB(104, 115, 129)
chatEmptyLabel.TextSize = 11
chatEmptyLabel.TextXAlignment = Enum.TextXAlignment.Left
chatEmptyLabel.Parent = chatHistory

local chatSignature = ""

local function renderChatMessages(messages)
	local signature = ""
	for _, message in ipairs(messages or {}) do
		signature = signature .. tostring(message.id) .. ":" .. tostring(message.status) .. ";"
	end
	if signature == chatSignature then
		return
	end
	chatSignature = signature

	for _, child in ipairs(chatHistory:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	chatEmptyLabel.Visible = not messages or #messages == 0

	for index, message in ipairs(messages or {}) do
		local isAssistant = message.role == "assistant"

		local bubble = Instance.new("Frame")
		bubble.LayoutOrder = index
		bubble.AutomaticSize = Enum.AutomaticSize.Y
		bubble.Size = UDim2.new(1, -4, 0, 0)
		bubble.BackgroundColor3 = isAssistant and Color3.fromRGB(28, 40, 38) or Color3.fromRGB(28, 34, 46)
		bubble.BorderSizePixel = 0
		bubble.Parent = chatHistory

		local bubbleCorner = Instance.new("UICorner")
		bubbleCorner.CornerRadius = UDim.new(0, 10)
		bubbleCorner.Parent = bubble

		local bubblePadding = Instance.new("UIPadding")
		bubblePadding.PaddingTop = UDim.new(0, 6)
		bubblePadding.PaddingBottom = UDim.new(0, 6)
		bubblePadding.PaddingLeft = UDim.new(0, 10)
		bubblePadding.PaddingRight = UDim.new(0, 10)
		bubblePadding.Parent = bubble

		local bubbleList = Instance.new("UIListLayout")
		bubbleList.Padding = UDim.new(0, 2)
		bubbleList.SortOrder = Enum.SortOrder.LayoutOrder
		bubbleList.Parent = bubble

		local roleLabel = Instance.new("TextLabel")
		roleLabel.LayoutOrder = 1
		roleLabel.BackgroundTransparency = 1
		roleLabel.Size = UDim2.new(1, 0, 0, 14)
		roleLabel.Font = Enum.Font.GothamSemibold
		roleLabel.Text = isAssistant and "Codex" or "You"
		roleLabel.TextColor3 = isAssistant and Color3.fromRGB(124, 247, 212) or Color3.fromRGB(145, 156, 171)
		roleLabel.TextSize = 11
		roleLabel.TextXAlignment = Enum.TextXAlignment.Left
		roleLabel.Parent = bubble

		local textLabel = Instance.new("TextLabel")
		textLabel.LayoutOrder = 2
		textLabel.BackgroundTransparency = 1
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.Size = UDim2.new(1, 0, 0, 0)
		textLabel.Font = Enum.Font.Gotham
		textLabel.Text = tostring(message.text or "")
		textLabel.TextColor3 = Color3.fromRGB(240, 244, 248)
		textLabel.TextSize = 12
		textLabel.TextWrapped = true
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		textLabel.Parent = bubble
	end

	task.defer(function()
		chatHistory.CanvasPosition = Vector2.new(0, math.max(0, chatHistory.AbsoluteCanvasSize.Y))
	end)
end

local function refreshChat()
	local response = safeRequest("GET", "/api/chat/messages?limit=50")
	if response and response.Success and response.Body then
		local ok, payload = pcall(function()
			return HttpService:JSONDecode(response.Body)
		end)
		if ok and payload then
			renderChatMessages(payload.messages or {})
		end
	end
end

local function sendChatMessage()
	local text = (chatInputBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then
		return
	end
	local response = safeRequest("POST", "/api/chat/send", { text = text })
	if response and response.Success then
		chatInputBox.Text = ""
		messageLabel.Text = "Sent to Codex inbox."
		refreshChat()
	else
		messageLabel.Text = "Failed to send chat message."
	end
end

chatSendButton.MouseButton1Click:Connect(sendChatMessage)
chatInputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		sendChatMessage()
	end
end)

local function connectPropertyEditorSignals()
	if selectionPropertyNameBox then
		selectionPropertyNameBox:GetPropertyChangedSignal("Text"):Connect(function()
			refreshPropertyEditorState()
			renderPropertyFavorites()
		end)
	end
	if selectionPropertyValueBox then
		selectionPropertyValueBox:GetPropertyChangedSignal("Text"):Connect(function()
			persistEditorState()
		end)
	end
end

local function connectSelectionTreeSignals()
	if selectionTreeFilterBox then
		selectionTreeFilterBox:GetPropertyChangedSignal("Text"):Connect(function()
			applyTreeFilter(selectionTreeFilterBox.Text or "")
		end)
	end
end

local function clearJobs()
	for _, child in ipairs(jobList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function renderJobs(jobs)
	clearJobs()
	for _, job in ipairs(jobs or {}) do
		local row = Instance.new("Frame")
		row.BackgroundColor3 = Color3.fromRGB(28, 34, 46)
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, -2, 0, 58)
		row.Parent = jobList

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 10)
		rowCorner.Parent = row

		local typeLabel = Instance.new("TextLabel")
		typeLabel.BackgroundTransparency = 1
		typeLabel.Position = UDim2.new(0, 10, 0, 8)
		typeLabel.Size = UDim2.new(1, -120, 0, 18)
		typeLabel.Font = Enum.Font.GothamSemibold
		typeLabel.Text = tostring(job.type or "-")
		typeLabel.TextColor3 = Color3.fromRGB(240, 244, 248)
		typeLabel.TextSize = 12
		typeLabel.TextXAlignment = Enum.TextXAlignment.Left
		typeLabel.Parent = row

		local statusColor = Color3.fromRGB(145, 156, 171)
		if job.status == "done" then
			statusColor = Color3.fromRGB(124, 247, 212)
		elseif job.status == "failed" then
			statusColor = Color3.fromRGB(244, 104, 104)
		end

		local statusLabel = Instance.new("TextLabel")
		statusLabel.BackgroundTransparency = 1
		statusLabel.AnchorPoint = Vector2.new(1, 0)
		statusLabel.Position = UDim2.new(1, -10, 0, 8)
		statusLabel.Size = UDim2.new(0, 90, 0, 18)
		statusLabel.Font = Enum.Font.GothamSemibold
		statusLabel.Text = tostring(job.status or "-")
		statusLabel.TextColor3 = statusColor
		statusLabel.TextSize = 12
		statusLabel.TextXAlignment = Enum.TextXAlignment.Right
		statusLabel.Parent = row

		local metaLabel = Instance.new("TextLabel")
		metaLabel.BackgroundTransparency = 1
		metaLabel.Position = UDim2.new(0, 10, 0, 28)
		metaLabel.Size = UDim2.new(1, -20, 0, 16)
		metaLabel.Font = Enum.Font.Gotham
		metaLabel.Text = tostring(job.id or "")
		metaLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
		metaLabel.TextSize = 11
		metaLabel.TextXAlignment = Enum.TextXAlignment.Left
		metaLabel.Parent = row

		local detailLabel = Instance.new("TextLabel")
		detailLabel.BackgroundTransparency = 1
		detailLabel.Position = UDim2.new(0, 10, 0, 42)
		detailLabel.Size = UDim2.new(1, -20, 0, 14)
		detailLabel.Font = Enum.Font.Gotham
		detailLabel.TextSize = 10
		detailLabel.TextXAlignment = Enum.TextXAlignment.Left
		if job.status == "done" and type(job.result) == "table" then
			detailLabel.TextColor3 = Color3.fromRGB(124, 247, 212)
			local summary = job.result.path or job.result.message or job.result.property or job.result.className or "ok"
			detailLabel.Text = "Result: " .. tostring(summary)
		elseif job.status == "failed" and job.error then
			detailLabel.TextColor3 = Color3.fromRGB(244, 104, 104)
			detailLabel.Text = "Error: " .. tostring(job.error)
		else
			detailLabel.TextColor3 = Color3.fromRGB(145, 156, 171)
			detailLabel.Text = "Queued for bridge processing."
		end
		detailLabel.Parent = row
	end
end

local function updatePanelState(payload)
	if not payload then
		serverValue.Text = "offline"
		bridgeValue.Text = "offline"
		statusBadge.Text = "disconnected"
		statusBadge.BackgroundColor3 = Color3.fromRGB(78, 52, 52)
		messageLabel.Text = "Dashboard unavailable."
		return
	end

	serverValue.Text = tostring(payload.version or "-")
	local bridge = payload.bridge or {}
	bridgeValue.Text = bridge.connected and "connected" or "disconnected"
	statusBadge.Text = bridge.connected and "online" or "offline"
	statusBadge.BackgroundColor3 = bridge.connected and Color3.fromRGB(39, 95, 78) or Color3.fromRGB(78, 52, 52)
	if bridge.connected then
		messageLabel.Text = string.format("Bridge: %s", tostring(bridge.clientName or "Roblox Studio"))
	else
		messageLabel.Text = "Bridge not connected yet."
	end
end

local function refreshPanel()
	local stateResponse = safeRequest("GET", "/api/state")
	if stateResponse and stateResponse.Success and stateResponse.Body then
		local ok, payload = pcall(function()
			return HttpService:JSONDecode(stateResponse.Body)
		end)
		if ok then
			updatePanelState(payload)
		else
			updatePanelState(nil)
		end
	else
		updatePanelState(nil)
	end

	local jobsResponse = safeRequest("GET", "/api/jobs")
	if jobsResponse and jobsResponse.Success and jobsResponse.Body then
		local ok, payload = pcall(function()
			return HttpService:JSONDecode(jobsResponse.Body)
		end)
		if ok and payload then
			renderJobs(payload.jobs or {})
		end
	end
end

local function queuePanelJob(jobType, payload)
	local response = safeRequest("POST", "/api/jobs", {
		type = jobType,
		payload = payload or {},
	})
	if response and response.Success and response.Body then
		messageLabel.Text = string.format("Queued %s.", jobType)
		return true
	end
	messageLabel.Text = string.format("Failed to queue %s.", jobType)
	return false
end

makeButton(buttonRow, "Ping", function()
	queuePanelJob("ping", {
		selection = serializeSelection(),
	})
end)

makeButton(buttonRow, "Selection", function()
	queuePanelJob("inspect_selection", {})
end)

makeButton(buttonRow, "Snapshot", function()
	queuePanelJob("sync_snapshot", {})
end)

makeButton(buttonRow, "Refresh", function()
	refreshPanel()
end)

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	if widget.Enabled then
		refreshPanel()
		refreshSelectionView()
		renderPropertyQuickReads()
		refreshPropertyHistory()
	end
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled then
		refreshPanel()
		refreshSelectionView()
		renderPropertyQuickReads()
		renderPropertyFavorites()
		refreshPropertyHistory()
		refreshPropertyEditorState()
	end
end)

Selection.SelectionChanged:Connect(function()
	refreshSelectionView()
end)

loadPropertyState()
loadPropertyFavorites()
if selectionTreeFilterBox then
	selectionTreeFilterBox.Text = loadTreeFilter()
end
loadEditorState()
connectSelectionTreeSignals()
connectPropertyEditorSignals()
applyTreeFilter(selectionTreeFilterBox and selectionTreeFilterBox.Text or "")

task.spawn(function()
	while running do
		pcall(heartbeat)
		pcall(refreshChat)
		local ok, response = pcall(request, "GET", "/api/bridge/next?clientId=" .. HttpService:UrlEncode(CLIENT_ID))
		if ok and response and response.Success and response.Body then
			local payload = HttpService:JSONDecode(response.Body)
			local job = payload and payload.job
			if job then
				local success, result = executeJob(job)
				pcall(request, "POST", "/api/bridge/result", {
					jobId = job.id,
					result = result,
					error = success and nil or tostring(result),
				})
			end
		end
		task.wait(POLL_INTERVAL)
	end
end)

widget.Enabled = true
refreshPanel()
refreshChat()
refreshSelectionView()
renderPropertyQuickReads()
renderPropertyFavorites()
refreshPropertyHistory()
refreshPropertyEditorState()

plugin.Unloading:Connect(function()
	running = false
end)
