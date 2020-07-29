local _, addon = ...

-- Create GradeFrame class
local GradeFrame = {}
GradeFrame.__index = GradeFrame
function GradeFrame:New()
	local self = {}
	setmetatable(self, GradeFrame)
	return self
end

--- App function to build this class
-- @param parent <Frame>
-- @return <GradeFrame>
function DEPGP:BuildGradeFrame(parent)
	local grade_frame = GradeFrame:New()
	grade_frame:Build(parent)
	return grade_frame
end

function GradeFrame:Build(parent)
	self.item_id = nil
	self.icon_size = 18
	self.max_num_rows = 6
	self.max_num_cols = 18
	self.grade_text_width = 13
	self.price_text_width = 30
	self.frame = CreateFrame("Frame", nil, parent)
	self.frame:SetPoint("TOPLEFT", 0, 0)
	self:Resize(0, 0)

	self.textures = {}
	self.grade_texts = {}
	self.price_texts = {}
	for row = 1, self.max_num_rows do
		local y_offset = -1 * ((row - 1) * self.icon_size + 2)
		self.textures[row] = {}
		self.grade_texts[row] = self.frame:CreateFontString(self.frame, "OVERLAY", "GameFontNormalSmall")
		self.grade_texts[row]:SetPoint("TOPLEFT", 0, y_offset)
		self.grade_texts[row]:SetSize(self.grade_text_width, self.icon_size)
		self.grade_texts[row]:SetText(nil)
		self.grade_texts[row]:SetJustifyH("CENTER")
		self.price_texts[row] = self.frame:CreateFontString(self.frame, "OVERLAY", "GameFontNormalSmall")
		self.price_texts[row]:SetPoint("TOPLEFT", self.grade_text_width, y_offset)
		self.price_texts[row]:SetSize(self.price_text_width, self.icon_size)
		self.price_texts[row]:SetText(nil)
		self.price_texts[row]:SetJustifyH("CENTER")
		local text_width = self.grade_text_width + self.price_text_width
		for col = 1, self.max_num_cols do
			local x_offset = (col - 1) * self.icon_size + text_width
			self.textures[row][col] = self.frame:CreateTexture(nil, "OVERLAY")
			self.textures[row][col]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", x_offset, y_offset)
			self.textures[row][col]:SetSize(self.icon_size - 1, self.icon_size - 1)
		end
	end
end

function GradeFrame:Clear()
	for row = 1, self.max_num_rows do
		self.grade_texts[row]:SetText(nil)
		self.price_texts[row]:SetText(nil)
	end
	for row = 1, self.max_num_rows do
		for col = 1, self.max_num_cols do
			self.textures[row][col]:SetTexture(nil)
		end
	end
	self:Resize(0, 0)
end

function GradeFrame:Resize(rows, cols)
	self.frame:SetSize(self.icon_size * cols + self.grade_text_width + self.price_text_width, self.icon_size * rows)
end

function GradeFrame:UpdateItem(item_id)
	if item_id == self.item_id then
		return
	end
	self.item_id = item_id

	self:Clear()

	local item_data = addon.app.data.items[item_id]
	if item_data == nil then
		self.frame:Hide()
		return
	end

	self.frame:Show()

	local num_rows = sizeof(item_data.by_grade)
	if item_data.price ~= nil then
		num_rows = num_rows + 1
	end
	local num_cols = 0
	for grade, grade_data in pairs(item_data.by_grade) do
		num_cols = max(num_cols, sizeof(grade_data.specs))
	end
	self:Resize(num_rows, num_cols)

	local grades = table_get_keys(item_data.by_grade)
	table.sort(grades)

	local row = 1
	for _, grade in pairs(grades) do
		grade_data = item_data.by_grade[grade]
		self.grade_texts[row]:SetText(addon.app.grades[grade])
		self.price_texts[row]:SetText(grade_data.price)
		local specs_as_keys = table_flip(grade_data.specs)
		local col = 1
		for _, spec in pairs(addon.app.specs) do
			if specs_as_keys[spec] ~= nil then
				self.textures[row][col]:SetTexture(addon.app.spec_textures[spec])
				col = col + 1
			end
		end
		row = row + 1
	end

	if item_data.price ~= nil then
		self.grade_texts[row]:SetText("*")
		self.price_texts[row]:SetText(item_data.price)
	end
end
