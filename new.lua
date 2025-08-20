local cloneref = cloneref or function() return end

--Locals
local Players = cloneref(game:GetService("Players"))
local InputService = game:GetService('UserInputService');
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = cloneref(game:GetService("Workspace"))
local Camera = Workspace.CurrentCamera
local Udim2 = UDim2
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

--Tables
Library = {
    FontFace=Font.new("rbxasset://fonts/families/NotoSans.json",Enum.FontWeight.Bold),
    Colors = {
        Background = Color3.fromRGB(17,23,29),
        ItemBorder = Color3.fromRGB(23,32,38),
        ItemBackground = Color3.fromRGB(30,38,44),
        Text=Color3.fromRGB(245,245,245),
        Active = Color3.fromRGB(0,255,239),
        DisabledText=Color3.fromRGB(134,134,134),
        Risky=Color3.fromRGB(235, 63, 0),
    },
    Functions = {},
    Flags = {},
    Connections = {},
    Registery = {},
    NotifyOnError=false,
    ScreenGui=nil;
    NotificationPosition="Top_Left";
    Toggles={};
    Options={};
    ThemeManger={};
    SaveManager={};
    Locals={};
    KeybindContainer = nil;
    CurrentRainbowColor = nil;
    CurrentRainbowHue = nil;
}

local Notifications = {};
local PlayerList={};
local TeamList={};
local RainbowColorPickers = {};
local OpenDropdowns = {};local OpenContextMenus = {};
local Toggles = Library.Toggles
local Options = Library.Options

makefolder("Float_Balls")
makefolder("Float_Balls/Ui")
makefolder("Float_Balls/Ui/Themes")
makefolder("Float_Balls/Ui/Games")

--Functions
local ThemeManager = {} do
	ThemeManager.Folder = 'Float_Balls/Ui/Themes'
	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
        ['Default'] = {1, HttpService:JSONDecode('{"DisabledText":{"Rainbow":false,"HexColor":"868686"},"ItemBorder":{"Rainbow":false,"HexColor":"161f26"},"Active":{"Rainbow":false,"HexColor":"00ffef"},"Background":{"Rainbow":false,"HexColor":"11171d"},"ItemBackground":{"Rainbow":false,"HexColor":"1d252c"},"Text":{"Rainbow":false,"HexColor":"f5f5f5"}}')};
        ['Interwebz'] = {2,HttpService:JSONDecode('{"DisabledText":{"Rainbow":false,"HexColor":"969696"},"ItemBorder":{"Rainbow":false,"HexColor":"3a2d51"},"Active":{"Rainbow":false,"HexColor":"e35649"},"Background":{"Rainbow":false,"HexColor":"221634"},"ItemBackground":{"Rainbow":false,"HexColor":"2b1f42"},"Text":{"Rainbow":false,"HexColor":"e6e6e6"}}')};
        ['OneTap'] = {3,HttpService:JSONDecode('{"DisabledText":{"Rainbow":false,"HexColor":"969696"},"ItemBorder":{"Rainbow":false,"HexColor":"121217"},"Active":{"Rainbow":false,"HexColor":"faa618"},"Background":{"Rainbow":false,"HexColor":"18181c"},"ItemBackground":{"Rainbow":false,"HexColor":"212125"},"Text":{"Rainbow":false,"HexColor":"ffffff"}}')};
        ['GameSense'] = {4,HttpService:JSONDecode('{"DisabledText":{"Rainbow":false,"HexColor":"828282"},"ItemBorder":{"Rainbow":false,"HexColor":"2c2c2e"},"Active":{"Rainbow":false,"HexColor":"89a936"},"Background":{"Rainbow":false,"HexColor":"101010"},"ItemBackground":{"Rainbow":false,"HexColor":"171717"},"Text":{"Rainbow":false,"HexColor":"f7f7f7"}}')};
        ['Astral'] = {5,HttpService:JSONDecode('{"DisabledText":{"Rainbow":false,"HexColor":"a7a8ab"},"ItemBorder":{"Rainbow":false,"HexColor":"313542"},"Active":{"Rainbow":false,"HexColor":"ff8787"},"Background":{"Rainbow":false,"HexColor":"282d3c"},"ItemBackground":{"Rainbow":false,"HexColor":"353a49"},"Text":{"Rainbow":false,"HexColor":"f3f3f3"}}')};
    }

	function ThemeManager:ApplyTheme(theme)
        local customThemeData = self:GetCustomTheme(theme)
        local data = customThemeData or self.BuiltInThemes[theme]
        if not data then return end
        local scheme = data[2]
        for idx, col in next, customThemeData or scheme do
            Library.Colors[idx] = Color3.fromHex(col.HexColor)
            if Options[idx.."Color"] then
                Options[idx.."Color"]:SetValueRGB(Color3.fromHex(col.HexColor))
                Options[idx.."Color"].Rainbow = col.Rainbow
            end
        end

        self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local options = { "Background", "Active", "ItemBorder", "ItemBackground", "Text" , "DisabledText", "Risky"}
		for i, field in next, options do
			if Options and Options[field.."Color"] then
				Library.Colors[field] = Options[field.."Color"].Value
			end
		end
		Library.Functions:UpdateColors()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder..'default.theme') and readfile(self.Folder..'default.theme')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
        if theme ~= nil then
		    writefile(self.Folder.."default.theme", theme)
        end
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddColorPicker('BackgroundColor', {Text = "Background Color"; Default = Library.Colors.Background });
		groupbox:AddColorPicker('ActiveColor', {Text = "Accent Color"; Default = Library.Colors.Active });
        groupbox:AddColorPicker('ItemBorderColor', {Text = "Outline Color"; Default = Library.Colors.ItemBorder });
        groupbox:AddColorPicker('ItemBackgroundColor', {Text = "Item Background Color";Default = Library.Colors.ItemBackground });
		groupbox:AddColorPicker('TextColor', {Text = "Text Color";Default = Library.Colors.Text });
        groupbox:AddColorPicker('DisabledTextColor', {Text = "Disabled Text Color";Default = Library.Colors.DisabledText });
        groupbox:AddColorPicker('RiskyTextColor', {Text = "Risky Text Color";Default = Library.Colors.Risky });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		local ThemeManagerList = groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Themes', Values = ThemesArray, Default = 1 })

		groupbox:AddButton({Text='Set As Default', Func=function()
			self:SaveDefault(ThemeManagerList.Value)
			self.Library:Notify({Title="Theme";Text=string.format('Set Default Theme To %q', ThemeManagerList.Value);Duration=3})
		end})

		ThemeManagerList:OnChanged(function()
			self:ApplyTheme(ThemeManagerList.Value)
		end)

		groupbox:AddDivider()
		local CustomThemeName = groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom Theme Name' })
		local CustomThemeList =  groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom Themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddDivider()
		
		groupbox:AddButton({Text='Save Theme', Func=function() 
			self:SaveCustomTheme(CustomThemeName.Value)

			CustomThemeList:SetValues(self:ReloadCustomThemes())
			CustomThemeList:SetValue(nil)
            Library:Notify({Title="Theme",Text=string.format('Saved Theme %q', CustomThemeName.Value),Duration=3})
		end}):AddButton({Text='Load Theme', Func=function()
            if CustomThemeList.Value ~= nil and CustomThemeList.Value ~= '' then
                self:ApplyTheme(CustomThemeList.Value)
                Library:Notify({Title="Theme",Text=string.format('Loaded Theme %q', CustomThemeList.Value),Duration=3})
            end
		end})

        groupbox:AddButton({Text='Refresh List', Func=function() 
            CustomThemeList:SetValues(self:ReloadCustomThemes())
			CustomThemeList:SetValue(nil)
		end})

        groupbox:AddButton({Text='Set As Default', Func=function() 
			if CustomThemeList.Value ~= nil and CustomThemeList.Value ~= '' then
				self:SaveDefault(CustomThemeList.Value)
                Library:Notify({Title="Theme",Text=string.format('Set default theme to %q', CustomThemeList.Value),Duration=3})
			end
		end})

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.ActiveColor:OnChanged(UpdateTheme)
		Options.ItemBorderColor:OnChanged(UpdateTheme)
		Options.ItemBackgroundColor:OnChanged(UpdateTheme)
		Options.TextColor:OnChanged(UpdateTheme)
        Options.DisabledTextColor:OnChanged(UpdateTheme)
        Options.RiskyTextColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:GetCustomTheme(file)
        if file == nil then return nil end
		local path = self.Folder..file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		decoded = HttpService:JSONDecode(data)

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return Library:Notify({Title="ERROR",Text='File Name Cannot Be nil',Duration=3})
		end

		local theme = {}
		local fields = { "Background", "Active", "ItemBorder", "ItemBackground", "Text" , "DisabledText", "Risky"}

		for idx, field in pairs(fields) do
            if Options[field.."Color"] ~= nil then
                theme[field] = {HexColor = Options[field.."Color"].Value:ToHex(),Rainbow = Options[field.."Color"].Rainbow}
            end
		end
		writefile(self.Folder..file..'.theme', HttpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
        local list = {}
        for i,v in pairs(listfiles(self.Folder)) do
            local Filestring = string.split(v,"/")[4]
            if string.split(Filestring,".")[1] ~= "default" then
                table.insert(list,v)
            end
        end

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-6) == '.theme' then

				local pos = file:find('.theme', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(Library, 'Must Set ThemeManager.Library First!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(Library, 'Must Set ThemeManager.Library First!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(Library, 'Must Set ThemeManager.Library First!')
		self:CreateThemeManager(groupbox)
	end
end
local httpService = game:GetService('HttpService')

local SaveManager = {} do
	SaveManager.Folder = "Float_Balls/Ui/Games"
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex() }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value))
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] and data and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
        makefolder(self.Folder.."/"..folder)
		self.Folder = self.Folder.."/"..folder.."/";
	end

	function SaveManager:Save(name)
		local fullPath = self.Folder..name..'.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local encoded = HttpService:JSONEncode(data)

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		local file = self.Folder..name..'.json'
		if not isfile(file) then return false, 'Invalid File' end

		decoded = HttpService:JSONDecode(readfile(file))

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				self.Parser[option.type].Load(option.idx, option)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"Background", "Active", "ItemBorder", "ItemBackground", "Text" , "DisabledText", "Risky", -- themes
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
		})
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder)

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder..'autoload.txt') then
			local name = readfile(self.Folder..'autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify({Title="ERROR",Text='Failed to load autoload config: ' .. err,Duration=3})
			end
            if err ~= nil then
                self.Library:Notify({Title="Configs",Text=string.format('Auto loaded config %q', name) .. err,Duration=3})
            end
		end
	end


	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local section = tab:AddRightGroupbox('Configuration')

		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config List', Values = self:RefreshConfigList(), AllowNull = true })
		section:AddInput('SaveManager_ConfigName',    { Text = 'Config Name' })

		section:AddDivider()

		section:AddButton({Text='Create Config', Func=function()
			local name = Options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
                self.Library:Notify({Title="Configs",Text='Invalid config name (empty)',Duration=2})
			end

			local success, err = self:Save(name)
			if not success then
                return self.Library:Notify({Title="Configs",Text='Failed to save config: ',Duration=3})
			end

            self.Library:Notify({Title="Configs",Text=string.format('Created config %q', name),Duration=3})

			Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
			Options.SaveManager_ConfigList:SetValues()
			Options.SaveManager_ConfigList:SetValue(nil)
		end}):AddButton({Text='Load Config', Func=function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
                return self.Library:Notify({Title="Configs",Text='Failed to load config: '..err,Duration=3})
			end

            self.Library:Notify({Title="Configs",Text=string.format('Loaded config %q', name),Duration=3})
		end})

		section:AddButton({Text='Overwrite Config', Func=function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
                return self.Library:Notify({Title="Configs",Text='Failed to overwrite config: '..err,Duration=3})
			end

            self.Library:Notify({Title="Configs",Text=string.format('Overwrote config %q', name),Duration=3})
		end})
		
		section:AddButton({Text='Autoload Config', Func=function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder..'autoload.txt', name)
			SaveManager.AutoloadLabel:SetText('Current Autoload Config: ' .. name)
            self.Library:Notify({Title="Configs",Text=string.format('Set %q to auto load', name),Duration=3})
		end})

		section:AddButton({Text='Refresh Config List', Func=function()
			Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
			Options.SaveManager_ConfigList:SetValues()
			Options.SaveManager_ConfigList:SetValue(nil)
		end})

		SaveManager.AutoloadLabel = section:AddLabel("AutoLoadLabel",'Current Autoload Config: None')

		if isfile(self.Folder .. 'autoload.txt') then
			local name = readfile(self.Folder .. 'autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current Autoload Config: ' .. name)
		end

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end
end
Library.ThemeManager = ThemeManager;
Library.SaveManager = SaveManager;

function Library.Functions:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X,
                Mouse.Y - Instance.AbsolutePosition.Y
            );

            if ObjPos.Y > (Cutoff or 40) then
                return;
            end;

            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0,
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                    0,
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                );

                Game:GetService("RunService").RenderStepped:Wait();
            end;
        end;
    end)
end;
local function GetPlayersString()
    local PlayerList = Players:GetPlayers();

    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;

    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

    return PlayerList;
end;
local function GetTeamsString()
    local TeamList = Teams:GetTeams();

    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;

    table.sort(TeamList, function(str1, str2) return str1 < str2 end);
    
    return TeamList;
end;

function Library.Functions.GetTextBounds(Object) --TextLabel Or TextButton
    if Object:IsA("TextLabel") or Object:IsA("TextButton") then
        return Object.TextBounds
    end
end
function Library.Functions:AddToRegistery(Object,Propertys)
    if Object == nil or (Propertys == nil or type(Propertys)~="table") then return end
    Library.Registery[Object] = Propertys
end
function Library.Functions:ChangeObjectRegistery(Object,Propertys)
    Library.Registery[Object] = Propertys
    for i,v in pairs(Library.Registery) do
        for i2,v2 in pairs(v) do
            i[i2] = Library.Colors[v2]
        end
    end
end
function Library.Functions:CreateConnect(Service,Callback)
    local Connection = game:GetService("RunService")[Service]:Connect(Callback)
    table.insert(Library.Connections,Connection)
end
function Library.Functions:Create(Object,Propertys)
    if type(Object) == "userdata" and Object.ClassName then Object = Object.ClassName end
    local Object = Instance.new(Object)
    for i,v in pairs(Propertys) do
        Object[i] = v
    end
    if (Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox")) then
        Object.FontFace=Library.FontFace
    end
    return Object
end
function Library.Functions:Callback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);

    if not success then
        local _, i = event:find(":%d+: ");

        if not i then
            return Library:Notify({Title="ERROR",Text=event,Duration=3});
        end;

        return Library:Notify({Title="ERROR",Text=event:sub(i + 1),Duration=3});
    end;
end;

function Library.Functions:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;


function Library:AddToolTip(InfoStr, HoverInstance)
    local Tooltip = Library.Functions:Create('Frame', {
        BackgroundColor3 = Library.Colors.Background,
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 100,
        Parent = Library.ScreenGui,
        Visible = false,
    })

    local Label = Library.Functions:Create("TextLabel",{
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromOffset(0, 0);
        TextSize = 14;
        Text = InfoStr,
        TextColor3 = Library.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,
        Parent = Tooltip;
    });

    local TooltipCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=Tooltip})
    local TooltipStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=Tooltip})
    Library.Functions:AddToRegistery(TooltipStroke, {Color="ItemBorder"})
    Library.Functions:AddToRegistery(Tooltip, {BackgroundColor3="Background"})
    Library.Functions:AddToRegistery(Label, {TextColor3="Text"})
    Tooltip.Size = UDim2.new(0,Label.TextBounds.X+6,0,20)
    Label.Position = UDim2.new(0,3,0,Label.TextBounds.Y-4)

    local IsHovering = false

    HoverInstance.MouseEnter:Connect(function()
        IsHovering = true
    
        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true
    
        while IsHovering do
            RunService.Heartbeat:Wait()
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end
    end)
    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end

--Init
local ScreenGui = Library.Functions:Create("ScreenGui",{Parent=(gethui() or cloneref(game:GetService("CoreGui")) or Players.LocalPlayer.PlayerGui),ResetOnSpawn=false})
Library.ScreenGui = ScreenGui
local RainbowStep = 0
local Hue = 0
Library.Functions:CreateConnect("RenderStepped",function(Delta)
    RainbowStep = RainbowStep + Delta
    if RainbowStep >= (1 / 60) then
        RainbowStep = 0
        Hue = Hue + (1 / 400);
        if Hue > 1 then
            Hue = 0;
        end;
        Library.CurrentRainbowHue = Hue;
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
    end
    for i,v in pairs(RainbowColorPickers) do 
        v:SetValueRGB(Library.CurrentRainbowColor)
    end
    RunService.RenderStepped:Wait();
end)


--Main
local BaseGroupbox = {};
local BaseAddons = {};

do
    LibraryPartFuncsAddons = {}
    function LibraryPartFuncsAddons:AddKeyPicker(Idx,Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        if ToggleLabel == nil then return end 
        
        assert(Info.Default, 'AddKeyPicker: Missing default value.');

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle'; -- Always, Toggle, Hold
            Type = 'KeyPicker';
            KeybindIgnore=Info.IgnoreKeybindFrame or false;
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;

            SyncToggleState = Info.SyncToggleState or false;
        };

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle' }
            Info.Mode = 'Toggle'
        end
        local PickOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 30, 0, 17);
            ZIndex = 6;
            Parent = ToggleLabel;
        });
        local PickOuterCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=PickOuter})
        local PickOuterStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=PickOuter})
        Library.Functions:AddToRegistery(PickOuterStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(PickOuter, {BackgroundColor3="ItemBackground"})
        PickOuter.MouseEnter:Connect(function()
            TweenService:Create(PickOuterStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(PickOuterStroke,{Color="Active"})
        end)
        PickOuter.MouseLeave:Connect(function()
            TweenService:Create(PickOuterStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(PickOuterStroke,{Color="ItemBorder"})
        end)

        local DisplayLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(1, 0, 1, 0);
            BackgroundTransparency=1;
            TextSize = 15;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickOuter;
        });
        if Info.Default == "Insert" then
            DisplayLabel.Text = "Ins"
        elseif Info.Default == ("MouseButton1" or "MouseButton2") then
            DisplayLabel.Text="MB"..string.split(Info.Default,"MouseButton")[2]
        end
        Library.Functions:AddToRegistery(DisplayLabel, {TextColor3="Text"})
        local ModeSelectOuter = Library.Functions:Create('Frame', {
            Name = "Select";
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 6, ToggleLabel.AbsolutePosition.Y);
            Size = UDim2.new(0, 60, 0, 45 + 2);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
            BackgroundTransparency=1;
        });
        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 6, ToggleLabel.AbsolutePosition.Y);
        end);
        local ModeSelectInner = Library.Functions:Create('Frame', {
            BorderSizePixel=0;
            Size = UDim2.new(1, -1, 1, -1);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });
        local ModeSelectInnerCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=ModeSelectInner})
        local ModeSelectInnerStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=ModeSelectInner})
        Library.Functions:AddToRegistery(ModeSelectInner, {BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(ModeSelectInnerStroke, {Color="ItemBorder"})
        Library.Functions:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });

        local ContainerLabel = nil
        if KeyPicker.KeybindIgnore == false then
            ContainerLabel = Library.Functions:Create("TextLabel",{
                TextXAlignment = Enum.TextXAlignment.Left;
                Size = UDim2.new(1, 0, 0, 18);
                TextSize = 14;
                Visible = true;
                BackgroundTransparency=1;
                ZIndex = 201;
                Parent = Library.KeybindContainer.List;
            });
            
            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, ToggleLabel.Text, KeyPicker.Mode);
            ContainerLabel.Visible = true;
            Library.Functions:AddToRegistery(ContainerLabel, {TextColor3="Text"})
            local YSize = 0
            local XSize = 0
            for _, Label in next, Library.KeybindContainer.List:GetChildren() do
                if Label:IsA('TextLabel') and Label.Visible then
                    YSize = YSize + 18;
                    if (Label.TextBounds.X > XSize) then
                        XSize = Label.TextBounds.X
                    end
                end;
            end;
            Library.KeybindContainer.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23)
        end

        local Modes = {'Always','Toggle','Hold'};
        local ModeButtons = {};
        
        for Idx, Mode in next, Modes do
            local ModeButton = {};

            local Label = Library.Functions:Create('TextLabel',{
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 14;
                Text = Mode;
                ZIndex = 16;
                BackgroundTransparency=1;
                Parent = ModeSelectInner;
            });
            Library.Functions:AddToRegistery(Label, {TextColor3="Text"})

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect();
                end;
                KeyPicker.Mode = Mode;
                Library.Functions:ChangeObjectRegistery(Label,{TextColor3="Active"})
                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;
                Library.Functions:ChangeObjectRegistery(Label,{TextColor3="Text"})
            end;

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select();
                    --Save
                end;
            end);

            if Mode == KeyPicker.Mode then
                ModeButton:Select();
            end;

            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false;
                end

                local Key = KeyPicker.Value;

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            DisplayLabel.Text = Key;
            KeyPicker.Value = Key;
            ModeButtons[Mode]:Select();
            if ContainerLabel ~= nil then
                ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, ToggleLabel.Text, KeyPicker.Mode);
            end
            if DisplayLabel.Text == "Insert" then
                DisplayLabel.Text = "Ins"
            elseif DisplayLabel.Text == "Delete" then
                DisplayLabel.Text = "Del"
            elseif DisplayLabel.Text == "RightShift" then
                DisplayLabel.Text = "RShift"
            elseif DisplayLabel.Text == "LeftShift" then
                DisplayLabel.Text = "LShift"
            end
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker:DisplayKeyBindFrame()
            if ContainerLabel ~= nil and KeyPicker.Toggled == true and KeyPicker.KeybindIgnore == false then 
                Library.Functions:ChangeObjectRegistery(ContainerLabel,{TextColor3="Active"}) 
            elseif ContainerLabel ~= nil and KeyPicker.KeybindIgnore == false then 
                Library.Functions:ChangeObjectRegistery(ContainerLabel,{TextColor3="Text"}) 
            end
        end

        function KeyPicker:DoClick()
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(KeyPicker.Toggled)
            end

            Library.Functions:Callback(KeyPicker.Callback, KeyPicker.Toggled)
            Library.Functions:Callback(KeyPicker.Clicked, KeyPicker.Toggled)
            KeyPicker:DisplayKeyBindFrame()
        end

        PickOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and DisplayLabel ~= nil then
                Picking = true;
                DisplayLabel.Text = '';
                local Break;
                local Text = '';
                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then
                            Text = '';
                        end;
                        Text = Text .. '.';
                        DisplayLabel.Text = Text;
                        wait(0.4);
                    end;
                end);
                wait(0.2);
                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name;
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    end;

                    Break = true;
                    Picking = false;
                    if DisplayLabel == nil then return end
                    DisplayLabel.Text = Key;
                    if DisplayLabel.Text == "Insert" then
                        DisplayLabel.Text = "Ins"
                    elseif DisplayLabel.Text == "Delete" then
                        DisplayLabel.Text = "Del"
                    elseif DisplayLabel.Text == "RightShift" then
                        DisplayLabel.Text = "RShift"
                    elseif DisplayLabel.Text == "LeftShift" then
                        DisplayLabel.Text = "LShift"
                    end
                    KeyPicker.Value = Key;

                    Library.Functions:Callback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                    Library.Functions:Callback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)
                    if ContainerLabel ~= nil then
                        ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, ToggleLabel.Text, KeyPicker.Mode);
                    end

                    --Save

                    Event:Disconnect();
                end);
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                ModeSelectOuter.Visible = true;
            end;
        end);

        local Picking = false;
        InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value;
    
                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1 or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled
                            KeyPicker:DoClick()
                        end;
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key then
                        KeyPicker.Toggled = not KeyPicker.Toggled;
                        KeyPicker:DoClick()
                    end;
                elseif KeyPicker.Mode == 'Hold' then
                    if KeyPicker.Value == 'None' then
                        KeyPicker.Toggled = false;
                    end

                    local Key = KeyPicker.Value;
                    if Key == 'MB1' or Key == 'MB2' then
                        KeyPicker.Toggled = Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                        KeyPicker:DoClick()
                    else
                        KeyPicker.Toggled = InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                        KeyPicker:DoClick()
                    end;
                elseif KeyPicker.Mode == 'Always' then
                    KeyPicker.Toggled = true;
                    KeyPicker:DoClick()
                end;
            end;
    
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectInner.AbsolutePosition, ModeSelectInner.AbsoluteSize;
                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                    ModeSelectOuter.Visible = false;
                end;
            end;
            if ContainerLabel == nil then return end
            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, ToggleLabel.Text, KeyPicker.Mode);
        end)
        InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Hold' then
                    if KeyPicker.Value == 'None' then
                        KeyPicker.Toggled = false;
                    end

                    local Key = KeyPicker.Value;
                    if Key == 'MB1' or Key == 'MB2' then
                        KeyPicker.Toggled = Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                        KeyPicker:DoClick()
                    else
                        KeyPicker.Toggled = InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                        KeyPicker:DoClick()
                    end;
                end;
            end;
            if ContainerLabel ~= nil then
                ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, ToggleLabel.Text, KeyPicker.Mode);
            end
        end)
            
        Options[Idx] = KeyPicker;

        return self;
    end;
    function LibraryPartFuncsAddons:AddColorPicker(Idx,Info)
        local ToggleLabel = self.TextLabel;
    
        assert(Info.Default, 'AddColorPicker: Missing default value.');
        
        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Rainbow = Info.Rainbow or false;
            Title = type(Info.Title) == 'string' and Info.Title or ToggleLabel.Text..' Color Picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);
            ColorPicker.Hue = H;ColorPicker.Sat = S;ColorPicker.Vib = V;
        end;
        ColorPicker:SetHSVFromRGB(ColorPicker.Value)
        
        local DisplayFrame = Library.Functions:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderSizePixel=0;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 30, 0, 17);
            ZIndex = 6;
            Parent = ToggleLabel;
        });
        local DisplayCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=DisplayFrame})
        local DisplayStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=DisplayFrame})
        Library.Functions:AddToRegistery(DisplayStroke, {Color="ItemBorder"})
        local CheckerFrame = Library.Functions:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });

        local PickerFrameOuter = Library.Functions:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel=0;
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X+34, DisplayFrame.AbsolutePosition.Y),
            Size = UDim2.fromOffset(230, Info.Transparency and 294 or 276);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });
        local PickerDisplayCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=PickerFrameOuter})
        local PickerDisplayStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=PickerFrameOuter})
        Library.Functions:AddToRegistery(PickerDisplayStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(PickerFrameOuter, {BackgroundColor3="ItemBackground"})
        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X+34, DisplayFrame.AbsolutePosition.Y);
        end)

        local SatVibMapOuter = Library.Functions:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        local SatVibMap = Library.Functions:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 17;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapOuter;
        });
        local CursorOuter = Library.Functions:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 18;
            Parent = SatVibMap;
        });
        local CursorInner = Library.Functions:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 19;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = Library.Functions:Create('Frame', {
            BackgroundColor3=Color3.new(1,1,1);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        local HueCursor = Library.Functions:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 17;
            Parent = HueSelectorOuter;
        });

        local HueBoxOuter = Library.Functions:Create('Frame', {
            BorderSizePixel=1;
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameOuter;
        });
        Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxOuter;
        });
        local HueBox = Library.Functions:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.Colors.Text;
            TextSize = 14;
            TextStrokeTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxOuter;
        });

        local RgbBoxBase = Library.Functions:Create('Frame', {
            BorderSizePixel=1;
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -9, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameOuter;
        });
        Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = RgbBoxBase;
        });
        local RgbBox = Library.Functions:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'RGB color',
            Text = '255, 255, 255',
            TextColor3 = Library.Colors.Text;
            TextSize = 14;
            TextStrokeTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = RgbBoxBase;
        });

        local RainbowBoxBase = Library.Functions:Create('Frame', {
            BorderSizePixel=1;
            Position = UDim2.new(0, 4, 0, 253),
            Size = UDim2.new(1, -11, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameOuter;
        });
        Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = RainbowBoxBase;
        });
        local RainbowBoxButton = Library.Functions:Create('TextButton', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            Text = 'Rainbow',
            TextColor3 = Library.Colors.Text;
            TextSize = 14;
            TextStrokeTransparency = 1;
            BackgroundTransparency=1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = RainbowBoxBase;
        });
        
        Library.Functions:AddToRegistery(HueSelectorOuter, {BorderColor3="ItemBorder"})
        Library.Functions:AddToRegistery(SatVibMapOuter, {BorderColor3="ItemBorder"})
        Library.Functions:AddToRegistery(RgbBoxBase, {BorderColor3="ItemBorder",BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(RgbBox, {TextColor3="Text",PlaceholderColor3="DisabledText"})
        Library.Functions:AddToRegistery(RainbowBoxBase, {BorderColor3="ItemBorder",BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(RainbowBoxButton, {TextColor3="DisabledText"})
        Library.Functions:AddToRegistery(HueBoxOuter, {BorderColor3="ItemBorder",BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(HueBox, {TextColor3="Text",PlaceholderColor3="DisabledText"})

        local TransparencyBoxOuter, TransparencyCursor;

        if Info.Transparency then 
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameOuter;
            });
            Library.Functions:AddToRegistery(TransparencyBoxOuter, {BorderColor3="ItemBorder"})

            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxOuter;
            });

            TransparencyCursor = Library:Create('Frame', { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxOuter;
            });
        end;
        local DisplayLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            BackgroundTransparency=1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title,
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        Library.Functions:AddToRegistery(DisplayLabel, {TextColor3="Text"})

        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library.Functions:Create('Frame', {
                Name="Context";
                BorderSizePixel=0;
                ZIndex = 14,
                Visible = false,
                BackgroundTransparency=1,
                Parent = ScreenGui
            })

            ContextMenu.Inner = Library.Functions:Create('Frame', {
                BackgroundColor3 = Library.Background;
                BorderSizePixel=0;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1,-2, 1,-2);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });
            ContextMenu.InnerCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=ContextMenu.Inner})
            ContextMenu.InnerStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=ContextMenu.Inner,Color=Color3.fromRGB(255,255,255)})

            Library.Functions:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library.Functions:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });
            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset((DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,DisplayFrame.AbsolutePosition.Y + 1)
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(menuWidth + 10,ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 6)
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            Library.Functions:AddToRegistery(ContextMenu.Inner, {BackgroundColor3="ItemBackground",BorderColor3="ItemBorder"})
            Library.Functions:AddToRegistery(ContextMenu.InnerStroke, {Color="ItemBorder"})

            function ContextMenu:Show()
                self.Container.Visible = true
                OpenContextMenus[ContextMenu] = {Container=self.Container}
                for i,v in pairs(OpenContextMenus) do
                    if i ~= ContextMenu then
                        v.Container.Visible = false
                    end
                end
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library.Functions:Create("TextLabel",{
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    BackgroundTransparency=1;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });
                Library.Functions:AddToRegistery(Button, {TextColor3="Text"})


                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return
                    end

                    local tween = TweenService:Create(Button,TweenInfo.new(.1),{TextSize=11})
                    tween:Play()
                    tween.Completed:Connect(function()
                        TweenService:Create(Button,TweenInfo.new(.1),{TextSize=13}):Play()
                    end)
                    Callback()
                end)
                Button.MouseEnter:Connect(function()
                    Library.Functions:ChangeObjectRegistery(Button,{TextColor3="Active"})
                end)
                Button.MouseLeave:Connect(function()
                    Library.Functions:ChangeObjectRegistery(Button,{TextColor3="Text"})
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value;
                Library:Notify({Title="Information",Text="Copied color!",Duration=2})
            end)

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify({Title="Error",Text="You have not copied a color!",Duration=2})
                end
                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)


            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify({Title="Information",Text="Copied hex code to clipboard!",Duration=2})
            end)

            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify({Title="Information",Text="Copied RGB values to clipboard!",Duration=2})
            end)
        end

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;
        local HueSelectorGradient = Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorOuter;
        });

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            DisplayFrame.BackgroundColor3 = ColorPicker.Value;
            DisplayFrame.BackgroundTransparency = ColorPicker.Transparency;

            if TransparencyBoxOuter then
                TransparencyBoxOuter.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library.Functions:Callback(ColorPicker.Callback, ColorPicker.Value);
            Library.Functions:Callback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value)
        end;

        function ColorPicker:Show()
            for i, v in next, ScreenGui:GetChildren() do
                if v.Name == 'Color' then
                    v.Visible = false;
                end;
            end;

            PickerFrameOuter.Visible = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        
        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Enum.UserInputType.MouseMovement do
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RunService.RenderStepped:Wait();
                end;

                --Save
            end;
        end);

        HueSelectorOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Enum.UserInputType.MouseMovement do
                    local MinY = HueSelectorOuter.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorOuter.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RunService.RenderStepped:Wait();
                end;

                --Save
            end;
        end);

        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end;
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                if ContextMenu.Container.Visible then
                    ContextMenu:Hide()
                else
                    ContextMenu:Show()
                    ColorPicker:Hide()
                end
            end
        end);

        if TransparencyBoxOuter then
            TransparencyBoxOuter.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinX = TransparencyBoxOuter.AbsolutePosition.X;
                        local MaxX = MinX + TransparencyBoxOuter.AbsoluteSize.X;
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                        ColorPicker:Display();

                        RunService.RenderStepped:Wait();
                    end;

                    --Save
                end;
            end);
        end;

        DisplayFrame.MouseEnter:Connect(function()
            TweenService:Create(DisplayStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(DisplayStroke,{Color="Active"})
        end)
        DisplayFrame.MouseLeave:Connect(function()
            TweenService:Create(DisplayStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(DisplayStroke,{Color="ItemBorder"})
        end)

        RainbowBoxButton.Activated:Connect(function()
            ColorPicker.Rainbow = not ColorPicker.Rainbow
            local Tween = TweenService:Create(RainbowBoxButton,TweenInfo.new(.1),{TextSize=12})
            Tween:Play()
            Tween.Completed:Connect(function()
                TweenService:Create(RainbowBoxButton,TweenInfo.new(.05),{TextSize=14}):Play()
                if ColorPicker.Rainbow then
                    Library.Functions:ChangeObjectRegistery(RainbowBoxButton,{TextColor3="Text"})
                    table.insert(RainbowColorPickers,ColorPicker)
                else
                    Library.Functions:ChangeObjectRegistery(RainbowBoxButton,{TextColor3="DisabledText"})
                    table.remove(RainbowColorPickers,table.find(RainbowColorPickers,ColorPicker))
                end
            end)
        end)

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker

        return ColorPicker 
    end;
    BaseAddons.__index = LibraryPartFuncsAddons;
    BaseAddons.__namecall = function(Table, Key, ...)
        return LibraryPartFuncsAddons[Key](...);
    end;
end

do
    LibraryPartFuncs = {}
    function LibraryPartFuncs:AddBlank(Size)
        assert(Size, 'AddBlank: Missing size value.');
        local Groupbox = self;
        local Container = Groupbox.Container;

        Library.Functions:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;
    function LibraryPartFuncs:AddDivider()
        local Groupbox = self;
        local Container = self.Container

        local Divider = {
            Type = 'Divider',
        }

        Groupbox:AddBlank(3);
        local DividerOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderSizePixel=0;
            Size = UDim2.new(1, -4, 0, 3);
            ZIndex = 5;
            Parent = Container;
        });
        local DividerCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=DividerOuter})
        local DividerStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=DividerOuter})
        Library.Functions:AddToRegistery(DividerStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(DividerOuter, {BackgroundColor3="ItemBackground"})

        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end
    function LibraryPartFuncs:AddLabel(Idx,Text)
        assert(Text, 'AddLabel: Missing text value.');

        local Label = {Addons={};};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(1, -4, 0, 16);
            TextSize = 15;
            Text = Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            BackgroundTransparency=1;
            Parent = Container;
        });
        Library.Functions:AddToRegistery(TextLabel, {TextColor3="Text"})

        Library.Functions:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = TextLabel;
        });
        Label.TextLabel = TextLabel;
        Label.Container = Container;

        function Label:SetText(Text)
            TextLabel.Text = Text
            Groupbox:Resize()
        end
        setmetatable(Label, BaseAddons);
        Groupbox:AddBlank(5);
        Groupbox:Resize()

        Options[Idx] = Label

        return Label
    end
    function LibraryPartFuncs:AddButton(Info)
        assert(Info.Text,"AddButton: Missing text value.")

        local Button = {
            Text=Info.Text;
            Func=Info.Func or function() return end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextButton = Library.Functions:Create('TextButton', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderSizePixel=0;
            TextSize=15;
            AutoButtonColor=false;
            Text = Button.Text;
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container 
        });
        local ButtonCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=TextButton})
        local ButtonStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=TextButton})
        Library.Functions:AddToRegistery(TextButton, {BackgroundColor3="ItemBackground",TextColor3="Text"})
        Library.Functions:AddToRegistery(ButtonStroke, {Color="ItemBorder"})

        TextButton.Activated:Connect(function()
            Library.Functions:Callback(Button.Func);
            local Tween = TweenService:Create(TextButton,TweenInfo.new(.1),{TextSize=13})
            Tween:Play()
            Tween.Completed:Connect(function()
                TweenService:Create(TextButton,TweenInfo.new(.05),{TextSize=15}):Play()
            end)
        end)

        TextButton.MouseEnter:Connect(function()
            TweenService:Create(ButtonStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(ButtonStroke,{Color="Active"})
        end)
        TextButton.MouseLeave:Connect(function()
            TweenService:Create(ButtonStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(ButtonStroke,{Color="ItemBorder"})
        end)

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, TextButton)
            end
            return self
        end

        function Button:AddButton(Info)
            local SubButton = {
                Text=Info.Text or "Button";
                Func = Info.Func or function() return end
        }

            TextButton.Size = UDim2.new(0.5, -4, 0, 20)
            local SubTextButton = Library.Functions:Create('TextButton', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderSizePixel=0;
                TextSize=15;
                AutoButtonColor=false;
                Text = SubButton.Text;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, 0, 1, 0);
                Position = UDim2.new(1, 4, 0, 0);
                ZIndex = 5;
                Parent = TextButton
            });
            local SubButtonCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=SubTextButton})
            local SubButtonStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=SubTextButton})
            Library.Functions:AddToRegistery(SubTextButton, {BackgroundColor3="ItemBackground",TextColor3="Text"})
            Library.Functions:AddToRegistery(SubButtonStroke, {Color="ItemBorder"})

            SubTextButton.Activated:Connect(function()
                Library.Functions:Callback(SubButton.Func);
                local Tween = TweenService:Create(SubTextButton,TweenInfo.new(.1),{TextSize=13})
                Tween:Play()
                Tween.Completed:Connect(function()
                    TweenService:Create(SubTextButton,TweenInfo.new(.05),{TextSize=15}):Play()
                end)
            end)
    
            SubTextButton.MouseEnter:Connect(function()
                TweenService:Create(SubButtonStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
                Library.Functions:ChangeObjectRegistery(SubButtonStroke,{Color="Active"})
            end)
            SubTextButton.MouseLeave:Connect(function()
                TweenService:Create(SubButtonStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
                Library.Functions:ChangeObjectRegistery(SubButtonStroke,{Color="ItemBorder"})
            end)

            return SubButton
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize()
        return Button
    end
    function LibraryPartFuncs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local InputLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 15;
            BackgroundTransparency=1;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });
        Library.Functions:AddToRegistery(InputLabel, {TextColor3="Text"})

        Groupbox:AddBlank(2);

        local TextBoxOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });
        local TextBoxCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=TextBoxOuter})
        local TextBoxStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=TextBoxOuter})
        Library.Functions:AddToRegistery(TextBoxStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(TextBoxOuter, {BackgroundColor3="ItemBackground"})

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        TextBoxOuter.MouseEnter:Connect(function()
            TweenService:Create(TextBoxStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(TextBoxStroke,{Color="Active"})
        end)
        TextBoxOuter.MouseLeave:Connect(function()
            TweenService:Create(TextBoxStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(TextBoxStroke,{Color="ItemBorder"})
        end)

        local Container = Library.Functions:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            ZIndex = 7;
            Parent = TextBoxOuter;
        })

        local Box = Library.Functions:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),
            PlaceholderText = Info.Placeholder or '';
            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 15;
            TextStrokeTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 7;
            Parent = Container;
        });
        Library.Functions:AddToRegistery(Box, {PlaceholderColor3="DisabledText",TextColor3="Text"})

        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text;
            Box.Text = Text;

            Library.Functions:Callback(Textbox.Callback, Textbox.Value);
            Library.Functions:Callback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then return end

                Textbox:SetValue(Box.Text);
                --Save
            end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                --Save
            end);
        end

        local function Update()
            local PADDING = 2
            local reveal = Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X
                    local currentCursorPos = Box.Position.X.Offset + width
                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Func(Textbox.Value);
        end;

        function Textbox:AddTooltip(string)
            if type(string) == "string" then
                Library:AddToolTip(string,TextBoxOuter)
            end
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        return Textbox;
    end;
    function LibraryPartFuncs:AddToggle(Idx,Info)
        assert(Info.Text, 'AddToggle: Missing `Text` string.')
        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';

            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky or false,
        };
        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 20, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });
        local ToggleLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(0, 275, 0, 20);
            Position=UDim2.new(0,26,0,0);
            TextSize = 15;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            BackgroundTransparency=1;
            Parent = ToggleOuter;
        });
        local ToggleButtonImage = Library.Functions:Create("ImageLabel",{
            BackgroundColor3 = Color3.new(0, 0, 0);
            BackgroundTransparency=1;
            Size=UDim2.new(1,0,1,0);
            Position=UDim2.new(0,0,0,0);
            BorderSizePixel=0;
            Image="http://www.roblox.com/asset/?id=6023426926";
            ImageColor3=Color3.fromRGB(17, 23, 29);
            ZIndex = 6;
            Parent=ToggleOuter;
        })
        local ToggleCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=ToggleOuter})
        local ToggleStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=ToggleOuter})
        Library.Functions:AddToRegistery(ToggleStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(ToggleOuter, {BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(ToggleLabel, {TextColor3="Text"})
    
        Library.Functions:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });
        local ToggleRegion = Library.Functions:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        });
        ToggleRegion.Size = Udim2.new(0,ToggleLabel.TextBounds.X+25,1,0)

        ToggleOuter.MouseEnter:Connect(function()
            TweenService:Create(ToggleStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(ToggleStroke,{Color="Active"})
        end)
        ToggleOuter.MouseLeave:Connect(function()
            TweenService:Create(ToggleStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(ToggleStroke,{Color="ItemBorder"})
        end)

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle:Display()
            if Toggle.Value == true then
                local Tween = TweenService:Create(ToggleOuter,TweenInfo.new(.15,Enum.EasingStyle.Quart),{BackgroundColor3=Library.Colors.Active})
                Tween:Play()
                Tween.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(ToggleOuter,{BackgroundColor3="Active"})
                end)
                local Tween = TweenService:Create(ToggleLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors.Text})
                Tween:Play()
                Tween.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(ToggleLabel,{TextColor3="Text"})
                end)
                ToggleButtonImage.Visible=true
                local Tween = TweenService:Create(ToggleButtonImage,TweenInfo.new(.15,Enum.EasingStyle.Quart),{ImageTransparency=0})
                Tween:Play()
            else
                local Tween = TweenService:Create(ToggleOuter,TweenInfo.new(.15,Enum.EasingStyle.Quart),{BackgroundColor3=Library.Colors.ItemBackground})
                Tween:Play()
                Tween.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(ToggleOuter,{BackgroundColor3="ItemBackground"})
                end)
                local Tween = TweenService:Create(ToggleLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors.DisabledText})
                Tween:Play()
                Tween.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(ToggleLabel,{TextColor3="DisabledText"})
                end)
                local Tween = TweenService:Create(ToggleButtonImage,TweenInfo.new(.15,Enum.EasingStyle.Quart),{ImageTransparency=1})
                Tween:Play()
                Tween.Completed:Connect(function()
                    ToggleButtonImage.Visible=false
                end)   
            end
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func(Toggle.Value)
        end

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);

            Toggle.Value = Bool;
            Toggle:Display();
            if Toggle.Value == true then
                ToggleButtonImage.Visible=true
            end

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:DisplayKeyBindFrame()
                end
            end

            Library.Functions:Callback(Toggle.Callback, Toggle.Value);
            Library.Functions:Callback(Toggle.Changed, Toggle.Value);
        end

        function Toggle:AddTooltip(string)
            if type(string) == "string" then
                Library:AddToolTip(string,ToggleRegion)
            end
        end

        ToggleRegion.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Toggle:SetValue(not Toggle.Value)
            end;
        end);

        if Toggle.Risky == true then
            Library.Functions:ChangeObjectRegistery(ToggleLabel,{TextColor3="Risky"})
        end

        Groupbox:AddBlank(5)
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;
        Toggle:Display()

        return Toggle
    end
    function LibraryPartFuncs:AddSlider(Idx,Info)
        assert(Info.Default, 'AddSlider: Missing default value.');
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min, 'AddSlider: Missing minimum value.');
        assert(Info.Max, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddSlider: Missing rounding value.');

        local Slider = {
            Value = Info.Default;
            OldDefault = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            MaxSize = 261;
            Type = 'Slider';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local SliderFrame = Library.Functions:Create("Frame",{
            BackgroundColor3=Color3.fromRGB(0,0,0);
            Size=Udim2.new(1,0,0,44);
            Position=Udim2.new(0,0,0,0);
            Parent=Container;
            BackgroundTransparency=1;
        })
        local SliderLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(1, 0, 0, 20);
            TextSize = 15;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            BackgroundTransparency=1;
            TextColor3=Library.Colors.Text;
            Parent = SliderFrame;
        })
        local SliderOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Library.Colors.ItemBackground;
            BorderSizePixel=0;
            Position = UDim2.new(0,0,0,22);
            Size = UDim2.new(0, 261, 0, 20);
            ZIndex = 6;
            Parent = SliderFrame;
        });
        local TextBoxFrame = Library.Functions:Create("Frame",{
            BorderSizePixel=0;
            Position = UDim2.new(0,264,0,22);
            Size = UDim2.new(0, 39, 0, 20);
            ZIndex = 7;
            Parent = SliderFrame;
        })
        local TextBoxValue = Library.Functions:Create("TextBox",{
            BackgroundTransparency=1;
            BorderSizePixel=0;
            Position = UDim2.new(0,0,0,0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 8;
            Parent = SliderOuter;
            PlaceholderText=Slider.Value;
            TextSize=15;
            Text=Slider.Value;
            Parent = TextBoxFrame;
        })
        local SliderCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=SliderOuter})
        local SliderStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=SliderOuter})
        Library.Functions:AddToRegistery(SliderLabel, {TextColor3="Text"})
        Library.Functions:AddToRegistery(SliderOuter, {BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(SliderStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(TextBoxValue, {PlaceholderColor3="DisabledText",TextColor3="Text"})
        Library.Functions:AddToRegistery(TextBoxFrame,{BackgroundColor3="ItemBackground"})

        if Slider.Value == Slider.Min then
            local Tween = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
            Tween:Play()
            Tween.Completed:Connect(function()
                Library.Functions:ChangeObjectRegistery(SliderLabel,{TextColor3="DisabledText"})
            end)
            local Tween2 = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
            Tween2:Play()
            Tween2.Completed:Connect(function()
                Library.Functions:ChangeObjectRegistery(TextBoxValue,{PlaceholderColor3="DisabledText"})
            end)
            local Tween3 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
            Tween3:Play()
            Tween3.Completed:Connect(function()
                Library.Functions:ChangeObjectRegistery(TextBoxValue,{TextColor3="DisabledText"})
            end)
        else
            local Tween = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
            Tween:Play()
            Tween.Completed:Connect(function()
                Library.Functions:ChangeObjectRegistery(SliderLabel,{TextColor3="Text"})
            end)
            local Tween2 = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
            Tween2:Play()
            Tween2.Completed:Connect(function()
                Library.Functions:ChangeObjectRegistery(TextBoxValue,{PlaceholderColor3="Text"})
            end)
            local Tween3 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
            Tween3:Play()
            Tween3.Completed:Connect(function()
                Library.Functions:ChangeObjectRegistery(TextBoxValue,{TextColor3="Text"})
            end)
        end

        local Fill = Library.Functions:Create('Frame', {
            BackgroundColor3 = Library.Colors.Active;
            BorderSizePixel=0;
            Position = UDim2.new(0,0,0,0);
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderOuter;
        });
        Library.Functions:AddToRegistery(Fill, {BackgroundColor3="Active"})
        local SliderFillCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=Fill})
        
        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.Value);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(tonumber(Value));
            end
            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
        end;
        function Slider:SetValue(Str)
            local Num = tonumber(Str);
            if (not Num) then
                return;
            end;

            Num = math.clamp(Num, Slider.Min, Slider.Max);

            Slider.Value = Num;
            local X = math.ceil(Library.Functions:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
            Fill.Size = UDim2.new(0, X, 1, 0);
            TextBoxValue.Text=Slider.Value
            TextBoxValue.PlaceholderText=Slider.Value

            Library.Functions:Callback(Slider.Callback, Slider.Value);
            Library.Functions:Callback(Slider.Changed, Slider.Value);
            if Slider.Value == Slider.Min then
                local Tween = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
                Tween:Play()
                Tween.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(SliderLabel,{TextColor3="DisabledText"})
                end)
                local Tween2 = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
                Tween2:Play()
                Tween2.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(TextBoxValue,{PlaceholderColor3="DisabledText"})
                end)
                local Tween3 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
                Tween3:Play()
                Tween3.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(TextBoxValue,{TextColor3="DisabledText"})
                end)
            else
                local Tween = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
                Tween:Play()
                Tween.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(SliderLabel,{TextColor3="Text"})
                end)
                local Tween2 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
                Tween2:Play()
                Tween2.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(TextBoxValue,{PlaceholderColor3="Text"})
                end)
                local Tween3 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
                Tween3:Play()
                Tween3.Completed:Connect(function()
                    Library.Functions:ChangeObjectRegistery(TextBoxValue,{TextColor3="Text"})
                end)
            end
        end;

        function Slider:GetValueFromXOffset(X)
            return Round(Library.Functions:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
        end;

        TextBoxValue.FocusLost:Connect(function()
            Slider:SetValue(Round(string.gsub(TextBoxValue.Text, "%D%p", "")))
        end)

        SliderOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mPos = Mouse.X;
                local gPos = Fill.Size.X.Offset;
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Enum.UserInputType.MouseMovement do
                    local nMPos = Mouse.X;
                    local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

                    local nValue = Slider:GetValueFromXOffset(nX);
                    local OldValue = Slider.Value;
                    Slider.Value = nValue;

                    local X = math.ceil(Library.Functions:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
                    Fill.Size = UDim2.new(0, X, 1, 0);
                    TextBoxValue.Text=Slider.Value
                    TextBoxValue.PlaceholderText=Slider.Value

                    if nValue ~= OldValue then
                        Library.Functions:Callback(Slider.Callback, Slider.Value);
                        Library.Functions:Callback(Slider.Changed, Slider.Value);
                    end;
                    if Slider.Value == Slider.Min then
                        local Tween = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
                        Tween:Play()
                        Tween.Completed:Connect(function()
                            Library.Functions:ChangeObjectRegistery(SliderLabel,{TextColor3="DisabledText"})
                        end)
                        local Tween2 = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
                        Tween2:Play()
                        Tween2.Completed:Connect(function()
                            Library.Functions:ChangeObjectRegistery(TextBoxValue,{PlaceholderColor3="DisabledText"})
                        end)
                        local Tween3 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["DisabledText"]})
                        Tween3:Play()
                        Tween3.Completed:Connect(function()
                            Library.Functions:ChangeObjectRegistery(TextBoxValue,{TextColor3="DisabledText"})
                        end)
                    else
                        local Tween = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
                        Tween:Play()
                        Tween.Completed:Connect(function()
                            Library.Functions:ChangeObjectRegistery(SliderLabel,{TextColor3="Text"})
                        end)
                        local Tween2 = TweenService:Create(SliderLabel,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
                        Tween2:Play()
                        Tween2.Completed:Connect(function()
                            Library.Functions:ChangeObjectRegistery(TextBoxValue,{PlaceholderColor3="Text"})
                        end)
                        local Tween3 = TweenService:Create(TextBoxValue,TweenInfo.new(.15,Enum.EasingStyle.Quart),{TextColor3=Library.Colors["Text"]})
                        Tween3:Play()
                        Tween3.Completed:Connect(function()
                            Library.Functions:ChangeObjectRegistery(TextBoxValue,{TextColor3="Text"})
                        end)
                    end

                    RunService.RenderStepped:Wait();
                end;

                --Save
            end;
        end);

        local X = math.ceil(Library.Functions:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
        Fill.Size = UDim2.new(0, X, 1, 0);
        TextBoxValue.Text=Slider.Value
        TextBoxValue.PlaceholderText=Slider.Value

        local TextBoxCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=TextBoxValue})
        local TextBoxStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=TextBoxValue})
        Library.Functions:AddToRegistery(TextBoxStroke, {Color="ItemBorder"})

        TextBoxValue.MouseEnter:Connect(function()
            TweenService:Create(TextBoxStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(TextBoxStroke,{Color="Active"})
        end)
        TextBoxValue.MouseLeave:Connect(function()
            TweenService:Create(TextBoxStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(TextBoxStroke,{Color="ItemBorder"})
        end)
        SliderOuter.MouseEnter:Connect(function()
            TweenService:Create(SliderStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(SliderStroke,{Color="Active"})
        end)
        SliderOuter.MouseLeave:Connect(function()
            TweenService:Create(SliderStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(SliderStroke,{Color="ItemBorder"})
        end)

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter)
        end

        function Slider:AddTooltip(string)
            if type(string) == "string" then
                Library:AddToolTip(string,SliderOuter)
            end
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize()

        Options[Idx] = Slider

        return Slider
    end
    function LibraryPartFuncs:AddDropdown(Idx,Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType; -- can be either 'Player' or 'Team'
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local RelativeOffset = 0;
        
        local DropdownFrame = Library.Functions:Create("Frame",{
            BackgroundColor3=Color3.fromRGB(0,0,0);
            Size=Udim2.new(1,0,0,20);
            Position=Udim2.new(0,0,0,0);
            Parent=Container;
            BackgroundTransparency=1;
        })

        local DropdownOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = DropdownFrame;
        });

        if not Info.Compact then
            DropdownFrame.Size=UDim2.new(1,0,0,40)
            local DropdownLabel = Library.Functions:Create("TextLabel",{
                Size = UDim2.new(1, -4, 0, 20);
                TextSize = 15;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                BackgroundTransparency=1;
                ZIndex = 5;
                Parent = DropdownFrame;
            });
            DropdownOuter.Position = UDim2.new(0,0,0,20)
            Library.Functions:AddToRegistery(DropdownLabel, {TextColor3="Text"})
        end
        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;
        local DropdownCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=DropdownOuter})
        local DropdownStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=DropdownOuter})
        Library.Functions:AddToRegistery(DropdownOuter, {BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(DropdownStroke, {Color="ItemBorder"})

        local DropdownArrow = Library.Functions:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16, 0.53, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 6;
            Parent = DropdownOuter;
        });
        Library.Functions:AddToRegistery(DropdownArrow, {ImageColor3="Text"})

        local ItemList = Library.Functions:Create("TextLabel",{
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 7;
            BackgroundTransparency=1;
            Parent = DropdownOuter;
        });
        Library.Functions:AddToRegistery(ItemList, {TextColor3="Text"})

        DropdownOuter.MouseEnter:Connect(function()
            TweenService:Create(DropdownStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(DropdownStroke,{Color="Active"})
        end)
        DropdownOuter.MouseLeave:Connect(function()
            TweenService:Create(DropdownStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(DropdownStroke,{Color="ItemBorder"})
        end)

        local MAX_DROPDOWN_ITEMS = 5;

        local ListOuter = Library.Functions:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });
        

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 3);
        end;
        local function RecalculateListSize(YSize)
            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, YSize or (MAX_DROPDOWN_ITEMS * 20 + 2))
        end;
        RecalculateListPosition();
        RecalculateListSize();
        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

        local ListOuterCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=ListOuter})
        local ListOuterStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=ListOuter})
        Library.Functions:AddToRegistery(ListOuter, {BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(ListOuterStroke, {Color="ItemBorder"})

        local Scrolling = Library.Functions:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Colors.Active,
        });
        Library.Functions:AddToRegistery(Scrolling, {ScrollBarImageColor3="Active"})

        Library.Functions:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end;

            ItemList.Text = (Str == '' and '--' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;
            local Buttons = {};

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    Element:Destroy();
                end;
            end;

            local Count = 0;

            for Idx, Value in next, Values do
                local Table = {};
                Count = Count + 1;

                local Button = Library.Functions:Create('TextButton', {
                    BackgroundColor3 = Library.Colors["ItemBackground"];
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, -1, 0, 20);
                    ZIndex = 23;
                    TextSize=14;
                    Text=Value;
                    Active = true,
                    Parent = Scrolling;
                });
                Library.Functions:AddToRegistery(Button, {BackgroundColor3="ItemBackground",TextColor3="Text"})

                local Selected;

                if Info.Multi then
                    Selected = Dropdown.Value[Value];
                else
                    Selected = Dropdown.Value == Value;
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    local ColorNeeded = Selected and "Active" or "Text";
                    Button.TextColor3 = Library.Colors[ColorNeeded]
                    Library.Functions:ChangeObjectRegistery(Button,{BackgroundColor3="ItemBackground",TextColor3=ColorNeeded})
                end;

                Button.Activated:Connect(function(Input)
                    local Try = not Selected;

                    if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                    else
                        if Info.Multi then
                            Selected = Try;
                            if Selected then
                                Dropdown.Value[Value] = true;
                            else
                                Dropdown.Value[Value] = nil;
                            end;
                        else
                            Selected = Try;
                            if Selected then
                                Dropdown.Value = Value;
                            else
                                Dropdown.Value = nil;
                            end;
                            for _, OtherButton in next, Buttons do
                                OtherButton:UpdateButton();
                            end;
                        end;
                        Table:UpdateButton();
                        Dropdown:Display();

                        Library.Functions:Callback(Dropdown.Callback, Dropdown.Value);
                        Library.Functions:Callback(Dropdown.Changed, Dropdown.Value);

                        --Save
                    end;
                end);

                Table:UpdateButton();
                Dropdown:Display();

                Buttons[Button] = Table;
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
            RecalculateListSize(Y);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues;
            end;
    
            Dropdown:BuildDropdownList();
        end;
    
        function Dropdown:OpenDropdown()
            ListOuter.Visible = true;
            TweenService:Create(DropdownArrow,TweenInfo.new(.15),{Rotation=180}):Play()
            OpenDropdowns[Dropdown] = {ListOuter=ListOuter,DropdownArrow=DropdownArrow}
            for i,v in pairs(OpenDropdowns) do
                if i ~= Dropdown then
                    v.ListOuter.Visible = false;
                    TweenService:Create(v.DropdownArrow,TweenInfo.new(.15),{Rotation=0}):Play()
                    OpenDropdowns[i] = nil
                end
            end
        end;
    
        function Dropdown:CloseDropdown()
            ListOuter.Visible = false;
            TweenService:Create(DropdownArrow,TweenInfo.new(.15),{Rotation=0}):Play()
            OpenDropdowns[Dropdown] = nil
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;
    
        function Dropdown:SetValue(Val)
            if Dropdown.Multi then
                local nTable = {};
    
                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true
                    end;
                end;
    
                Dropdown.Value = nTable;
            else
                if (not Val) then
                    Dropdown.Value = nil;
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;
    
            Dropdown:BuildDropdownList();
    
            Library.Functions:Callback(Dropdown.Callback, Dropdown.Value);
            Library.Functions:Callback(Dropdown.Changed, Dropdown.Value);
        end;
    
        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;
    
                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
    
                    Dropdown:CloseDropdown();
                end;
            end;
        end);

        Dropdown:BuildDropdownList();
        Dropdown:Display();

        local Defaults = {}

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default)
            if Idx then
                table.insert(Defaults, Idx)
            end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value)
                if Idx then
                    table.insert(Defaults, Idx)
                end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index];
                end

                if (not Info.Multi) then break end
            end

            Dropdown:BuildDropdownList();
            Dropdown:Display();
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize()

        Options[Idx] = Dropdown

        return Dropdown
    end
    function LibraryPartFuncs:AddColorPicker(Idx,Info)
        local Groupbox = self;
        local Container = Groupbox.Container;
    
        assert(Info.Default, 'AddColorPicker: Missing default value.');
        assert(Info.Text, 'AddColorPicker: Missing text value.');
        
        local ColorPicker = {
            Value = Info.Default;
            Text=Info.Text;
            Transparency = Info.Transparency or 0;
            Rainbow=Info.Rainbow or false;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);
            ColorPicker.Hue = H;ColorPicker.Sat = S;ColorPicker.Vib = V;
        end;
        ColorPicker:SetHSVFromRGB(ColorPicker.Value)
        local ColorPickerTextLabel = Library.Functions:Create('TextLabel', {
            BackgroundTransparency=1;
            BorderSizePixel=0;
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 6;
            TextXAlignment=Enum.TextXAlignment.Left;
            TextSize=15;
            Text=ColorPicker.Text;
            Parent = Container;
        });
        Library.Functions:AddToRegistery(ColorPickerTextLabel, {TextColor3="Text"})
        local TextLabelUIList = Library.Functions:Create('UIListLayout', {
            Padding=UDim.new(0,4);
            FillDirection=Enum.FillDirection.Horizontal;
            HorizontalAlignment=Enum.HorizontalAlignment.Right;
            VerticalAlignment=Enum.VerticalAlignment.Center;
            Parent=ColorPickerTextLabel;
        });
        
        local DisplayFrame = Library.Functions:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderSizePixel=0;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 30, 0, 17);
            ZIndex = 6;
            Parent = ColorPickerTextLabel;
        });
        local DisplayCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=DisplayFrame})
        local DisplayStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=DisplayFrame})
        Library.Functions:AddToRegistery(DisplayStroke, {Color="ItemBorder"})
        local CheckerFrame = Library.Functions:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });

        local PickerFrameOuter = Library.Functions:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel=0;
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X+34, DisplayFrame.AbsolutePosition.Y),
            Size = UDim2.fromOffset(230, Info.Transparency and 294 or 276);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });
        local PickerDisplayCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=PickerFrameOuter})
        local PickerDisplayStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=PickerFrameOuter})
        Library.Functions:AddToRegistery(PickerDisplayStroke, {Color="ItemBorder"})
        Library.Functions:AddToRegistery(PickerFrameOuter, {BackgroundColor3="ItemBackground"})
        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X+34, DisplayFrame.AbsolutePosition.Y);
        end)

        local SatVibMapOuter = Library.Functions:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        local SatVibMap = Library.Functions:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 17;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapOuter;
        });
        local CursorOuter = Library.Functions:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 18;
            Parent = SatVibMap;
        });
        local CursorInner = Library.Functions:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 19;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = Library.Functions:Create('Frame', {
            BackgroundColor3=Color3.new(1,1,1);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        local HueCursor = Library.Functions:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 17;
            Parent = HueSelectorOuter;
        });

        local HueBoxOuter = Library.Functions:Create('Frame', {
            BorderSizePixel=1;
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameOuter;
        });
        Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxOuter;
        });
        local HueBox = Library.Functions:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.Colors.Text;
            TextSize = 14;
            TextStrokeTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxOuter;
        });

        local RgbBoxBase = Library.Functions:Create('Frame', {
            BorderSizePixel=1;
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -9, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameOuter;
        });
        Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = RgbBoxBase;
        });
        local RgbBox = Library.Functions:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'RGB color',
            Text = '255, 255, 255',
            TextColor3 = Library.Colors.Text;
            TextSize = 14;
            TextStrokeTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = RgbBoxBase;
        });
        local RainbowBoxBase = Library.Functions:Create('Frame', {
            BorderSizePixel=1;
            Position = UDim2.new(0, 4, 0, 253),
            Size = UDim2.new(1, -11, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameOuter;
        });
        Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = RainbowBoxBase;
        });
        local RainbowBoxButton = Library.Functions:Create('TextButton', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            Text = 'Rainbow',
            TextColor3 = Library.Colors.Text;
            TextSize = 14;
            TextStrokeTransparency = 1;
            BackgroundTransparency=1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = RainbowBoxBase;
        });

        Library.Functions:AddToRegistery(HueSelectorOuter, {BorderColor3="ItemBorder"})
        Library.Functions:AddToRegistery(SatVibMapOuter, {BorderColor3="ItemBorder"})
        Library.Functions:AddToRegistery(RgbBoxBase, {BorderColor3="ItemBorder",BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(RgbBox, {TextColor3="Text",PlaceholderColor3="DisabledText"})
        Library.Functions:AddToRegistery(HueBoxOuter, {BorderColor3="ItemBorder",BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(HueBox, {TextColor3="Text",PlaceholderColor3="DisabledText"})
        Library.Functions:AddToRegistery(RainbowBoxBase, {BorderColor3="ItemBorder",BackgroundColor3="ItemBackground"})
        Library.Functions:AddToRegistery(RainbowBoxButton, {TextColor3="DisabledText"})

        local TransparencyBoxOuter, TransparencyCursor;

        if Info.Transparency then 
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameOuter;
            });
            Library.Functions:AddToRegistery(TransparencyBoxOuter, {BorderColor3="ItemBorder"})

            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxOuter;
            });

            TransparencyCursor = Library:Create('Frame', { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxOuter;
            });
        end;
        local DisplayLabel = Library.Functions:Create("TextLabel",{
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            BackgroundTransparency=1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title,
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        Library.Functions:AddToRegistery(DisplayLabel, {TextColor3="Text"})

        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library.Functions:Create('Frame', {
                Name="Context";
                BorderSizePixel=0;
                ZIndex = 14,
                Visible = false,
                BackgroundTransparency=1,
                Parent = ScreenGui
            })

            ContextMenu.Inner = Library.Functions:Create('Frame', {
                BackgroundColor3 = Library.Background;
                BorderSizePixel=0;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1,-2, 1,-2);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });
            ContextMenu.InnerCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=ContextMenu.Inner})
            ContextMenu.InnerStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=ContextMenu.Inner,Color=Color3.fromRGB(255,255,255)})

            Library.Functions:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library.Functions:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });
            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset((DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,DisplayFrame.AbsolutePosition.Y + 1)
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(menuWidth + 10,ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 6)
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            Library.Functions:AddToRegistery(ContextMenu.Inner, {BackgroundColor3="ItemBackground",BorderColor3="ItemBorder"})
            Library.Functions:AddToRegistery(ContextMenu.InnerStroke, {Color="ItemBorder"})

            function ContextMenu:Show()
                self.Container.Visible = true
                OpenContextMenus[ContextMenu] = {Container=self.Container}
                for i,v in pairs(OpenContextMenus) do
                    if i ~= ContextMenu then
                        v.Container.Visible = false
                    end
                end
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library.Functions:Create("TextLabel",{
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    BackgroundTransparency=1;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });
                Library.Functions:AddToRegistery(Button, {TextColor3="Text"})


                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return
                    end

                    local tween = TweenService:Create(Button,TweenInfo.new(.1),{TextSize=11})
                    tween:Play()
                    tween.Completed:Connect(function()
                        TweenService:Create(Button,TweenInfo.new(.1),{TextSize=13}):Play()
                    end)
                    Callback()
                end)
                Button.MouseEnter:Connect(function()
                    Library.Functions:ChangeObjectRegistery(Button,{TextColor3="Active"})
                end)
                Button.MouseLeave:Connect(function()
                    Library.Functions:ChangeObjectRegistery(Button,{TextColor3="Text"})
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value;
                Library:Notify({Title="Information",Text="Copied color!",Duration=2})
            end)

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify({Title="Error",Text="You have not copied a color!",Duration=2})
                end
                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)


            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify({Title="Information",Text="Copied hex code to clipboard!",Duration=2})
            end)

            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify({Title="Information",Text="Copied RGB values to clipboard!",Duration=2})
            end)
        end

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;
        local HueSelectorGradient = Library.Functions:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorOuter;
        });

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            DisplayFrame.BackgroundColor3 = ColorPicker.Value;
            DisplayFrame.BackgroundTransparency = ColorPicker.Transparency;

            if TransparencyBoxOuter then
                TransparencyBoxOuter.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library.Functions:Callback(ColorPicker.Callback, ColorPicker.Value);
            Library.Functions:Callback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value)
        end;

        function ColorPicker:Show()
            for i, v in next, ScreenGui:GetChildren() do
                if v.Name == 'Color' then
                    v.Visible = false;
                end;
            end;

            PickerFrameOuter.Visible = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        
        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Enum.UserInputType.MouseMovement do
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RunService.RenderStepped:Wait();
                end;

                --Save
            end;
        end);

        HueSelectorOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Enum.UserInputType.MouseMovement do
                    local MinY = HueSelectorOuter.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorOuter.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RunService.RenderStepped:Wait();
                end;

                --Save
            end;
        end);

        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end;
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                if ContextMenu.Container.Visible then
                    ContextMenu:Hide()
                else
                    ContextMenu:Show()
                    ColorPicker:Hide()
                end
            end
        end);

        if TransparencyBoxOuter then
            TransparencyBoxOuter.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinX = TransparencyBoxOuter.AbsolutePosition.X;
                        local MaxX = MinX + TransparencyBoxOuter.AbsoluteSize.X;
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                        ColorPicker:Display();

                        RunService.RenderStepped:Wait();
                    end;

                    --Save
                end;
            end);
        end;

        DisplayFrame.MouseEnter:Connect(function()
            TweenService:Create(DisplayStroke,TweenInfo.new(.1),{Color=Library.Colors["Active"]}):Play()
            Library.Functions:ChangeObjectRegistery(DisplayStroke,{Color="Active"})
        end)
        DisplayFrame.MouseLeave:Connect(function()
            TweenService:Create(DisplayStroke,TweenInfo.new(.1),{Color=Library.Colors["ItemBorder"]}):Play()
            Library.Functions:ChangeObjectRegistery(DisplayStroke,{Color="ItemBorder"})
        end)

        RainbowBoxButton.Activated:Connect(function()
            ColorPicker.Rainbow = not ColorPicker.Rainbow
            local Tween = TweenService:Create(RainbowBoxButton,TweenInfo.new(.1),{TextSize=12})
            Tween:Play()
            Tween.Completed:Connect(function()
                TweenService:Create(RainbowBoxButton,TweenInfo.new(.05),{TextSize=14}):Play()
                if ColorPicker.Rainbow then
                    Library.Functions:ChangeObjectRegistery(RainbowBoxButton,{TextColor3="Text"})
                else
                    Library.Functions:ChangeObjectRegistery(RainbowBoxButton,{TextColor3="DisabledText"})
                end
            end)
        end)
        Library.Functions:CreateConnect("Heartbeat",function()
            if ColorPicker.Rainbow then Library.Functions:ChangeObjectRegistery(RainbowBoxButton,{TextColor3="Text"}) else Library.Functions:ChangeObjectRegistery(RainbowBoxButton,{TextColor3="DisabledText"}) end
            if ColorPicker.Rainbow == true then
                local RBH,RBS,RBV = Color3.toHSV(Library.CurrentRainbowColor)
                ColorPicker.Transparency = Transparency or 0;
                ColorPicker:SetHSVFromRGB(Color3.fromHSV(RBH,ColorPicker.Sat,ColorPicker.Vib));
                ColorPicker:Display();
            end
        end)

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Groupbox:AddBlank(5);
        Groupbox:Resize()

        Options[Idx] = ColorPicker

        return ColorPicker
    end
    BaseGroupbox.__index = LibraryPartFuncs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return LibraryPartFuncs[Key](...);
    end;
end

function Library:Unload()
    --disconnect hooks/connections Before this is called!
    for i,v in pairs(Library.Connections) do
        v:Disconnect()
    end
    for i,v in pairs(Library.Toggles) do
        v:SetValue(false)
    end
    for i,v in pairs(Library.Options) do
        if v.Type == "Slider" then
            v:SetValue(v.OldDefault)
        end
    end
    ScreenGui:Destroy()
end

local NotificationHolder = Library.Functions:Create("Frame",{
    Size=UDim2.new(0, 275,0, 200);
    Position=UDim2.new(0,0,0,0);
    BackgroundTransparency=1;
    BorderSizePixel=0;
    ZIndex=199;
    Parent=ScreenGui;
})
local NotificationUiList = Library.Functions:Create('UIListLayout',{
    Padding = UDim.new(0,4),
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Top;
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificationHolder,
});
local KeybindOuter = Library.Functions:Create('Frame', {
    BorderSizePixel=0;
    AnchorPoint = Vector2.new(0, 0.5);
    Position = UDim2.new(0, 10, 0.5, 0);
    Size = UDim2.new(0, 200, 0, 23);
    ZIndex = 200;
    Visible = true;
    Parent = ScreenGui;
})
local KeybindTopInvis = Library.Functions:Create('Frame', {
    BorderSizePixel=0;
    Position = UDim2.new(0, 0, 0, 0);
    Size = UDim2.new(1, 0, 0, 2);
    ZIndex = 201;
    BackgroundTransparency=1;
    Visible = true;
    Parent = KeybindOuter;
})
local KeybindLabel = Library.Functions:Create("TextLabel",{
    Position = UDim2.new(0, 0, 0, 0);
    Size = UDim2.new(1, 0, 0, 15);
    Text = "Keybinds";
    TextSize = 15;
    BackgroundTransparency=1;
    TextXAlignment = Enum.TextXAlignment.Center;
    ZIndex = 202;
    Parent = KeybindOuter;
});
local List = Library.Functions:Create('Frame', {
    BorderSizePixel=0;
    Position = UDim2.new(0, 5, 0, 17);
    Size = UDim2.new(1, -6, 1, -17);
    ZIndex = 201;
    BackgroundTransparency=1;
    Visible = true;
    Name = "List";
    Parent = KeybindOuter;
});
Library.Functions:Create('UIListLayout', {
    FillDirection = Enum.FillDirection.Vertical;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = List;
});
local KeybindOuterCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=KeybindOuter})
local KeybindOuterStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=KeybindOuter})
Library.KeybindContainer = KeybindOuter

Library.Functions:AddToRegistery(KeybindOuter, {BackgroundColor3="ItemBackground"})
Library.Functions:AddToRegistery(KeybindOuterStroke, {Color="Active"})
Library.Functions:AddToRegistery(KeybindLabel, {TextColor3="Text"})
Library.Functions:MakeDraggable(KeybindOuter, 25);
local WatermarkOuter = Library.Functions:Create('Frame', {
    BorderSizePixel=0;
    Position = UDim2.new(0, 100, 0, -25);
    Size = UDim2.new(0, 213, 0, 20);
    ZIndex = 200;
    Visible = false;
    Parent = ScreenGui;
})
Library.Functions:MakeDraggable(WatermarkOuter, 25);
local WatermarkLabel = Library.Functions:Create("TextLabel",{
    Position = UDim2.new(0, 5, 0, 0);
    Size = UDim2.new(1, -5, 1, 0);
    TextSize = 15;
    BackgroundTransparency=1;
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = 201;
    Parent = WatermarkOuter;
});
local WatermarkOuterCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=WatermarkOuter})
local WatermarkOuterStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=WatermarkOuter})
Library.Functions:AddToRegistery(WatermarkOuter, {BackgroundColor3="ItemBackground"})
Library.Functions:AddToRegistery(WatermarkOuterStroke, {Color="Active"})
Library.Functions:AddToRegistery(WatermarkLabel, {TextColor3="Text"})

function Library:SetWatermarkVisible(Bool)
    WatermarkOuter.Visible = Bool
end;

function Library:SetWatermark(Text)
    WatermarkLabel.Text = Text
    local X, Y = WatermarkLabel.TextBounds.X,WatermarkLabel.TextBounds.Y
    WatermarkOuter.Size = UDim2.new(0, X + 10, 0, (Y * 1.5) + 3);
    Library:SetWatermarkVisible(true)

end;

function Library:Notify(Info)
    do
        assert(Info.Title,"Library:Notify, Missing title value")
        assert(Info.Text,"Library:Notify, Missing text value")
        
        Positions = {
            ["Bottom_Right"]=UDim2.new(1, -285, 1, -210);
            ["Bottom_Left"]=UDim2.new(0, 8, 1, -210);
            ["Top_Left"]=UDim2.new(0, 8, 0, 10);
            ["Top_Right"]=UDim2.new(1, -285, 0, 10);
        }

        Notification = {
            Title=Info.Title;
            Text=Info.Text;
            Duration=Info.Duration or 1;
            Position=Info.Position or Library.NotificationPosition;
        }
        local endTime = os.clock() + (Info.Duration or 1)
        if Notification.Position=="Top_Left" then
            NotificationUiList.VerticalAlignment = Enum.VerticalAlignment.Top
            NotificationUiList.HorizontalAlignment = Enum.HorizontalAlignment.Left
            NotificationHolder.Position=Positions[Notification.Position]
        elseif Notification.Position=="Top_Right" then
            NotificationUiList.VerticalAlignment = Enum.VerticalAlignment.Top
            NotificationUiList.HorizontalAlignment = Enum.HorizontalAlignment.Right
            NotificationHolder.Position=Positions[Notification.Position]
        elseif Notification.Position=="Bottom_Left" then
            NotificationUiList.VerticalAlignment = Enum.VerticalAlignment.Bottom
            NotificationUiList.HorizontalAlignment = Enum.HorizontalAlignment.Left
            NotificationHolder.Position=Positions[Notification.Position]
        elseif Notification.Position=="Bottom_Right" then
            NotificationUiList.VerticalAlignment = Enum.VerticalAlignment.Bottom
            NotificationUiList.HorizontalAlignment = Enum.HorizontalAlignment.Right
            NotificationHolder.Position=Positions[Notification.Position]
        end

        local NotificationOuter = Library.Functions:Create("Frame",{
            Size=UDim2.new(0, 275,0, 60);
            Position=Positions[Info.Position];
            BackgroundColor3=Library.Colors.ItemBackground;
            BorderSizePixel=0;
            Parent=NotificationHolder;
        })
        local NotificationCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,4),Parent=NotificationOuter})
        local NotificationStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=NotificationOuter,Color=Color3.fromRGB(255,255,255)})
        local Gradient = Library.Functions:Create('UIGradient', {
                Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.Colors.Active),ColorSequenceKeypoint.new(1, Library.Colors.ItemBorder)});
                Rotation = 0;
                Parent = NotificationStroke;
                Offset=Vector2.new(-1,0);
                Enabled=true;
            });
        Library.Functions:AddToRegistery(NotificationOuter, {BackgroundColor3="ItemBackground"})
        local NotificationTitle = Library.Functions:Create("TextLabel",{
            Size=UDim2.new(1, -4,0, 17);
            Position=UDim2.new(0,4,0,1);
            BackgroundTransparency=1;
            TextColor3=Library.Colors["Text"];
            Text=Info.Title.." | "..Info.Duration.."s";
            BorderSizePixel=0;
            TextSize=15;
            TextXAlignment=Enum.TextXAlignment.Left;
            Parent=NotificationOuter;
        })
        Library.Functions:AddToRegistery(NotificationTitle, {TextColor3="Text"})
        NotificationText = Library.Functions:Create("TextLabel",{
            Size=UDim2.new(1, -4,1, -17);
            Position=UDim2.new(0,4,1,-21);
            BackgroundTransparency=1;
            TextColor3=Library.Colors["Text"];
            Text=Info.Text;
            TextXAlignment=Enum.TextXAlignment.Left;
            TextSize=14;
            TextWrapped=true;
            BorderSizePixel=0;
            Parent=NotificationOuter;
        })
        Library.Functions:AddToRegistery(NotificationText, {TextColor3="Text"})
        Notifications[NotificationOuter] = {Started=tick(),Duration=Notification.Duration}

        if NotificationText.TextBounds.X > NotificationTitle.TextBounds.X then
            NotificationOuter.Size = UDim2.new(0,NotificationText.TextBounds.X+8,0,(20+NotificationText.TextBounds.Y+5))
        elseif NotificationTitle.TextBounds.X > NotificationText.TextBounds.X then
            NotificationOuter.Size = UDim2.new(0,NotificationTitle.TextBounds.X+8,0,(20+NotificationText.TextBounds.Y+5))
        else
            NotificationOuter.Size = UDim2.new(0,NotificationText.TextBounds.X+8,0,(20+NotificationText.TextBounds.Y+5))
        end

        TweenService:Create(Gradient,TweenInfo.new(Info.Duration-.3),{Offset=Vector2.new(1,0)}):Play()
        task.spawn(function()
            while os.clock() < endTime do task.wait()
                local timeLeft = endTime - os.clock()
                NotificationTitle.Text = Info.Title .. " | " .. string.format("%.1f", timeLeft) .. "s"
            end
            Notifications[NotificationOuter] = nil
            NotificationOuter:Destroy()
        end)
    end
end

function Library:CreateWindow(...)
    local Arguments = {...}
    local Config = {}

    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1]
    end

    if type(Config.Title) ~= 'string' then Config.Title = '[NO TITLE]' end
    if type(Config.FadeTime) ~= 'number' then Config.FadeTime = 0.2 end
    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    local Window = {
        Tabs = {};
    };

    local Background = Library.Functions:Create("Frame", {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Config.Position,
        Size = UDim2.new(0, 660,0, 400),
        Visible = true;
        ZIndex = 1;
        ClipsDescendants=true;
        Parent = ScreenGui;
    });
    Library.Functions:MakeDraggable(Background, 25);
    
    local BackgroundCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,6),Parent=Background})
    local BackgroundStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=3,Parent=Background})
    Library.Functions:AddToRegistery(Background, {BackgroundColor3="Background"})
    Library.Functions:AddToRegistery(BackgroundStroke, {Color="ItemBorder"})

    local WindowLabel = Library.Functions:Create("TextLabel",{
        Position = UDim2.new(0, (Background.Size.X.Offset/2), 0, 0);
        BackgroundTransparency=1,
        RichText=true,
        Size = UDim2.new(0, 0, 0, 25);
        TextSize=18,
        Text = 'Float<font color="#'..Library.Colors["Active"]:ToHex()..'">.Balls</font>' ..Config.Title or "";
        ZIndex = 1;
        Parent = Background;
    });
    function Library.Functions:UpdateColors()
        for i,v in next, Library.Registery do
            for i2,v2 in pairs(v) do
                i[i2] = Library.Colors[v2] 
            end
        end
        WindowLabel.Text = 'Float<font color="#'..Library.Colors["Active"]:ToHex()..'">.Balls</font>' ..Config.Title or "";
    end
    Library.Functions:AddToRegistery(WindowLabel, {TextColor3="Text"})
    local TitleLine = Library.Functions:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = UDim2.new(0, (Background.Size.X.Offset/94),0, WindowLabel.Size.Y.Offset),
        Size = UDim2.new(1, -15,0, 2),
        ZIndex = 1,
        Parent = Background,
    });
    Library.Functions:AddToRegistery(TitleLine, {BackgroundColor3="ItemBorder"})
    local TabMenu = Library.Functions:Create('ScrollingFrame', {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        BackgroundTransparency=1,
        Position = UDim2.new(0, (Background.Size.X.Offset/94),0, (WindowLabel.Size.Y.Offset+TitleLine.Size.Y.Offset+3)),
        Size = UDim2.new(1, -15,0, 30),
        AutomaticSize=Enum.AutomaticSize.X,
        HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        ScrollBarImageColor3 = Color3.new(0, 0, 0),
        ScrollBarThickness=2,
        CanvasSize=UDim2.new(0,0,0,0),
        ZIndex = 1,
        Parent = Background,
    });
    Library.Functions:AddToRegistery(TabMenu, {BackgroundColor3="Background",ScrollBarImageColor3="ItemBorder"})
    local TabUiList = Library.Functions:Create('UIListLayout',{
        Padding = UDim.new(0,2),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabMenu,
    });
    local MainSection = Library.Functions:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, (Background.Size.X.Offset/94),0, (WindowLabel.Size.Y.Offset+TitleLine.Size.Y.Offset+TabMenu.Size.Y.Offset+6)),
        Size = UDim2.new(1, -15,1, -71),
        ZIndex = 1,
        Parent = Background,
    });
    local MainSectionCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,8),Parent=MainSection})
    local MainSectionStroke = Library.Functions:Create('UIStroke', {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=2,Parent=MainSection})
    Library.Functions:AddToRegistery(MainSection, {BackgroundColor3="Background"})
    Library.Functions:AddToRegistery(MainSectionStroke, {Color="ItemBorder"})

    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;
    
    FirstTab = true
    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
        };

        local TabButton = Library.Functions:Create('Frame', {
            BackgroundColor3 = Library.Colors.Background;
            BorderSizePixel=0,
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 1;
            Parent = TabMenu;
        });
        Library.Functions:AddToRegistery(TabButton, {BackgroundColor3="Background"})
        local TabButtonClick = Library.Functions:Create("TextButton",{
            AutoButtonColor = false;
            Position = UDim2.new(0, 0, 0, 0);
            BorderSizePixel=0;
            TextSize=19;
            Size = UDim2.new(1, 0, 1, -2);
            Text = Name;
            ZIndex = 1;
            Parent = TabButton;
        });
        
        TabButton.Size = UDim2.new(0, math.clamp(TabButtonClick.TextBounds.X, 65, 300), 1, 0);
        Library.Functions:AddToRegistery(TabButtonClick, {BackgroundColor3="Background",TextColor3="Text"})
        local ActiveLine = Library.Functions:Create("Frame",{
            Name="ActiveLine",
            Size = UDim2.new(1, 0, 0, 2);
            Position = UDim2.new(0, 0, 1, 0);
            ZIndex = 2;
            Visible=false;
            Parent = TabButton;
        });
        Library.Functions:AddToRegistery(ActiveLine, {BackgroundColor3="Active"})

        local TabFrame = Library.Functions:Create("Frame",{
            BorderSizePixel=0;
            Size = UDim2.new(1, 0, 1, 0);
            Position = UDim2.new(0, 0, 0, 0);
            ZIndex = 2;
            Visible=false;
            Parent = MainSection;
        });
        local TabFrameCorner = Library.Functions:Create('UICorner', {CornerRadius=UDim.new(0,8),Parent=TabFrame})
        Library.Functions:AddToRegistery(TabFrame, {BackgroundColor3="Background"})
        local LeftSide = Library.Functions:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 7, 0, 7);
            Size = UDim2.new(0.5, -14, 1,-10);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });
        local RightSide = Library.Functions:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 5, 0, 7);
            Size = UDim2.new(0.5, -14, 1,-10);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });
        Library.Functions:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });
        Library.Functions:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });
        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
            end);
        end;

        function Tab:HideTab()
            local tween = TweenService:Create(ActiveLine,TweenInfo.new(.18,Enum.EasingStyle.Quart),{BackgroundTransparency=1})
            TabFrame.Visible = false
            tween:Play()
            tween.Completed:Connect(function()
                ActiveLine.Visible = false
            end)
        end
        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                if _ ~= Name then
                    Tab:HideTab()
                end
            end
            for i, v in next, ScreenGui:GetChildren() do
                if v.Name == 'Color' or v.Name == 'Context' or v.Name == "Select" then
                    v.Visible = false;
                end;
            end;
            
            ActiveLine.Visible = true
            TabFrame.Visible = true;
            TweenService:Create(ActiveLine,TweenInfo.new(.18,Enum.EasingStyle.Quart),{BackgroundTransparency=0}):Play()
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};

            local Box = Library.Functions:Create('Frame', {
                BackgroundColor3 = Library.Colors.Background;
                BackgroundTransparency=1;
                BorderSizePixel=0;
                Size = UDim2.new(1, 0, 0, 50);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });
            local GroupboxLabelFrame = Library.Functions:Create("Frame",{
                Size = UDim2.new(1, 0, 0, 22);
                BackgroundTransparency=1;
                Position = UDim2.new(0, 4, 0, 2);
                ZIndex = 5;
                Parent = Box;
            });
            local GroupboxLabel = Library.Functions:Create("TextLabel",{
                Size = UDim2.new(1, 0, 1, 0);
                BackgroundTransparency=1;
                Position = UDim2.new(0, 0, 0, 0);
                TextSize = 15;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 6;
                Parent = GroupboxLabelFrame;
            });
            Library.Functions:AddToRegistery(GroupboxLabel, {TextColor3="Text"})
            local GroupboxLineUnderTitle = Library.Functions:Create("Frame",{
                BackgroundColor3 = Library.Colors.Background;
                BackgroundTransparency=0;
                BorderSizePixel=0;
                Size = UDim2.new(0, GroupboxLabel.TextBounds.X+6, 0, 2);
                Position=UDim2.new(0,0,1,-2);
                ZIndex = 7;
                Parent = GroupboxLabelFrame
            })
            Library.Functions:AddToRegistery(GroupboxLineUnderTitle, {BackgroundColor3="Active"})
            local Container = Library.Functions:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 27);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 1;
                Parent = Box;
            });
            Library.Functions:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });
            function Groupbox:Resize()
                local Size = 0;

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        Size = Size + Element.Size.Y.Offset;
                    end;
                end;

                Box.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
            end;
            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);
            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            return Groupbox
        end

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name})
        end
        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name})
        end

        TabButtonClick.Activated:Connect(function(Input)
            Tab:ShowTab()
        end)

        if FirstTab == true then
            Tab:ShowTab()
            FirstTab = false
        end
        Window.Tabs[Name] = Tab;
        return Tab
    end

    local TransparencyCache = {};
    local Toggled = Background.Visible;
    local Fading = false;

    Library.Locals["MenuOpen"] = Background.Visible
    function Library:Toggle()
        if Fading then
            return;
        end;

        local FadeTime = Config.FadeTime;
        Fading = true;
        Toggled = (not Toggled);

        if Toggled then
            Background.Visible = true;
        end
        if Toggled == false then
            for i,v in pairs(OpenDropdowns) do
                v.ListOuter.Visible = false;
                TweenService:Create(v.DropdownArrow,TweenInfo.new(.15),{Rotation=0}):Play()
                OpenDropdowns[i] = nil
            end
            for i,v in pairs(OpenContextMenus) do
                v.Container.Visible = false
            end
        end

        for _, Desc in next, Background:GetDescendants() do
            local Properties = {};

            if Desc:IsA('ImageLabel') then
                table.insert(Properties, 'ImageTransparency');
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') or Desc:IsA("TextButton") then
                table.insert(Properties, 'TextTransparency');
            elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('UIStroke') then
                table.insert(Properties, 'Transparency');
            end;

            local Cache = TransparencyCache[Desc];

            if (not Cache) then
                Cache = {};
                TransparencyCache[Desc] = Cache;
            end;

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop];
                end;

                if Cache[Prop] == 1 then
                    continue;
                end;

                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
            end;
        end;

        task.wait(FadeTime);

        Background.Visible = Toggled;

        Fading = false;
        Library.Locals["MenuOpen"] = Toggled
    end

    return Window
end

--Loops
Library.Functions:CreateConnect("Heartbeat",function()
    ScreenGui.Name = HttpService:GenerateGUID()
end)

local function OnPlayerChange()
    local PlayerList = GetPlayersString();

    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);

return Library