----------------------------------
--Copyright (c) 2019 Brent Batch--
----------------------------------

if not guiBuilder then
	dofile("guiBuilder.lua")
end
-- gui test --

guitest = class( nil )
guitest.maxChildCount = 0
guitest.maxParentCount = 1
guitest.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
guitest.connectionOutput = 0
guitest.colorNormal = sm.color.new(0xe54500ff)
guitest.colorHighlight = sm.color.new(0xff7033ff)
guitest.poseWeightCount = 1
guitest.remoteguiposition = sm.vec3.new(0,0,2000) -- change this to prevent colliding with other gui blocks
guitest.remotedistance = 100 -- make this bigger if the size of your block is big

--[[server]]
function guitest.server_onCreate(self) -- spawn remote global gui block
	local uuid = self.shape:getShapeUuid()
	sm.shape.createPart( uuid, guitest.remoteguiposition, sm.quat.identity(), false, false ) 
end

function guitest.server_onFixedUpdate(self, dt)

end


--[[client]]
function guitest.client_onCreate(self)
end

function guitest.client_onSetupGui( self )
	-- only the remote shape can initialize a global gui:
	if (self.shape.worldPosition - self.remoteguiposition):length()>self.remotedistance or (guitestgui and guitestgui.instantiated) then return end
	guitestgui = guiBuilder("gui - test", 1100, 700)
	guitestgui.instantiated = true
	print("==gui setup loading==")
	
	guitestgui:setupGui(self)
	
	local bx, by = guitestgui.bgPosX, guitestgui.bgPosY -- background gui pos
	
	local optionmenu = optionMenuItem(bx + 100, by + 100, 500, 50)
	local item = optionmenu:addItem(0,0,500,50)
	
	local valuebox = item:addValueBox(250,0,150,50, "1")
	item:addLabel(0,0,250-27,50, "label for this value:")
	item:addDecreaseButton(250-27,5,27,40, "test", 
		function()
			valuebox:setText(tostring(tonumber(valuebox:getText())-1)) 
		end)
	item:addIncreaseButton(400,5,27,40, "test",
		function()
			valuebox:setText(tostring(tonumber(valuebox:getText())+1)) 
		end)
	guitestgui:addItemWithId("optionmenu1", optionmenu) -- HOW TO GET ITEMS BY CUSTOM ID IN ONINTERACT
	
	local collection = collectionItems({})
	collection:addItem(buttonSmallItem(bx + 700, by + 200, 100, 50, "tab abc 1111", function() collection:setVisible(false) end, "GUI Inventory highlight") )
	collection:addItem(buttonSmallItem(bx + 800, by + 200, 100, 50, "tab def 1111") )
	collection:addItem(buttonSmallItem(bx + 700, by + 250, 100, 50, "tab ghi 1111") )
	collection:addItem(buttonSmallItem(bx + 800, by + 250, 100, 50, "tab jkl 1111") )
	local collection2 = collectionItems({})
	collection2:addItem(buttonSmallItem(bx + 700, by + 200, 100, 50, "tab mno 222") )
	collection2:addItem(buttonSmallItem(bx + 800, by + 200, 100, 50, "tab pqr 222") )
	collection2:addItem(buttonSmallItem(bx + 700, by + 250, 100, 50, "tab stu 222") )
	collection2:addItem(buttonSmallItem(bx + 800, by + 250, 100, 50, "tab vwx 222") )
	
	local button1 = buttonSmallItem(bx + 650, by + 120, 150, 70, "tab 1", function()end--[[makes sure there is a bound onClick]])
	
	button1.onClick = 
	function()
		print(button1:getText())  -- example of onClick doing stuff to button itself, 
		sm.audio.play("GUI Inventory highlight") -- kills its playsound so add it again
	end 
	
	local button2 = buttonSmallItem(bx + 800, by + 120, 150, 70, "tab 2", function() print("tab2") end, "GUI Inventory highlight")
	local tabcontroll = 
		tabControllItem( -- makes it possible for the gui to manage collections visibility properly
			{
				button1,
				button2
			},
			{
				collection,
				collection2
			}
		)
		
	local pbutton1 = buttonSmallItem(bx + 650, by + 50, 150, 50, "parent tab1", nil, "GUI Inventory highlight")
	-- example nested tabControllItem:
	guitestgui:addItem(
		tabControllItem(
			{
				pbutton1,
				buttonSmallItem(bx + 800, by + 50, 150, 50, "parent tab2", nil, "GUI Inventory highlight")
			},
			{
				tabcontroll,
				buttonSmallItem(bx + 650, by+ 150, 300, 200, "parent tab\ncontent 2")
			}
		)
	)
	
	guitestgui:addItem(buttonSmallItem(bx + 650, by + 400, 200, 100, "<button no border>", function()print('lol')end, "GUI Inventory highlight", false ))
	
	guitestgui:addItem(labelItem(bx + 50, by + 400, 200, 100, "#df7000label\nborder" ))
	guitestgui:addItem(labelItem(bx + 250, by + 400, 200, 100, "#ff0000label\nnoborder", nil , nil, false))
	local textbox = textBoxItem(bx + 450, by + 400, 100, 100, "#00ff00textboxvalue")
	guitestgui:addItem(textbox)
	
	guitestgui:addItem(buttonSmallItem(bx + 450, by + 250, 100, 50, "small", 
		function()
			sm.gui.displayAlertText("HEHE\t\t\tLOL", 1)
			print('test')
			print(textbox:getText())
		end), "GUI Inventory highlight")
	
	
	guitestgui:addItem(buttonItem(bx + guitestgui.width - 50, by + 0, 50, 50, "#ff0000X", 
		function()
			guitestgui:hide()
		end))
	--guitestgui:addItem(invisibleBoxItem(bx, by,0, 0, guitestgui.width - 50, 50,
	--	function()
	--		guitestgui:hide()
	--	end))
end

function guitest.client_onUpdate(self, dt)
	-- has to exist for gui to not break, gets overwritten for the global one
end

function guitest.client_onInteract(self)
	if not guitestgui then print("guitestgui not instantiated due to refresh, please place a new block") return end
	--print(guitestgui.items.optionmenu1.items[1].label) -- example
	
	-- fill GLOBAL gui with self.values first:
	guitestgui.items.optionmenu1.items[1].valueBox.widget:setText(self.savedvalue or "0")
	
	guitestgui:show() 
	guitestgui.on_hide =
	function()
		--print(self.shape)
		-- save values in self here, then send over network 
		self.savedvalue = guitestgui.items.optionmenu1.items[1].valueBox.widget:getText()
	end
end

function guitest.client_onDestroy(self)
	if guitestgui then guitestgui:setVisible(false, true) end-- set gui invisible without showing messages (displayalert)
end



-- /* Script Developer tools:
function guitest.client_onRefresh(self)
	if guitestgui and (self.shape.worldPosition - self.remoteguiposition):length()<self.remotedistance then -- globalgui
		if guitestgui then guitestgui:hide() end 
		guitestgui = nil
	end
	self:client_onCreate() 
end
function guitest.server_onRefresh(self) -- re-create gui so that it can show new items added when refreshing, old blocks break!
	if (self.shape.worldPosition - self.remoteguiposition):length()<self.remotedistance then
		sm.shape.destroyShape( self.shape, 0 )
		sm.shape.createPart( self.shape:getShapeUuid(), self.remoteguiposition, sm.quat.identity(), false, true ) 
	end
	self:server_onCreate()
end
-- */ Script Developer tools

