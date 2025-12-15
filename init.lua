local Drag    = {}
Drag.__index  = Drag

-- Metadata
Drag.name     = "Drag"
Drag.version  = "0.1"
Drag.author   = "Michael Mogenson"
Drag.homepage = "https://github.com/mogenson/drag.spoon"
Drag.license  = "MIT - https://opensource.org/licenses/MIT"

-- helper time function

local function wait(seconds)
    local start = hs.timer.secondsSinceEpoch()
    while hs.timer.secondsSinceEpoch() - start < seconds do end
end

-- helper mouse functions

local function mouseMove(position)
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.mouseMoved, position):post()
end

local function mouseDown(position)
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDown, position):post()
end

local function mouseUp(position)
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp, position):post()
end

local function mouseClick(position)
    mouseDown(position)
    mouseUp(position)
end

local function mouseDrag(start_position, end_position)
    mouseMove(start_position)
    mouseDown(start_position)
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDragged, end_position):post()
    mouseUp(end_position)
end

-- helper mission control functions

function getMissionControlGroup()
    local dock_app = hs.application.applicationsForBundleID("com.apple.dock")[1]
    local dock_element = hs.axuielement.applicationElement(dock_app)
    for _, element in ipairs(dock_element) do
        if element.AXIdentifier == "mc" then
            return element
        end
    end

    return nil, "mission control is not open"
end

function getDisplayGroups()
    local mc_group, err = getMissionControlGroup()
    if err then
        return nil, err
    end

    local display_groups = {}
    for _, element in ipairs(mc_group) do
        if element.AXIdentifier == "mc.display" then
            table.insert(display_groups, element)
        end
    end

    return display_groups
end

function getMissionControlWindows()
    local display_groups, err = getDisplayGroups()
    if err then
        return nil, err
    end

    local windows = {}
    for _, group in ipairs(display_groups) do
        for _, element in ipairs(group) do
            if element.AXIdentifier == "mc.windows" then
                for _, mc_window in ipairs(element) do
                    table.insert(windows, mc_window)
                end
            end
        end
    end

    return windows
end

function getMissionControlSpaces()
    local display_groups, err = getDisplayGroups()
    if err or not display_groups then
        return nil, err
    end

    local spaces = {}
    for _, display_group in ipairs(display_groups) do
        for _, element in ipairs(display_group) do
            if element.AXIdentifier == "mc.spaces" then
                local mc_spaces = element
                for _, element in ipairs(mc_spaces) do
                    if element.AXIdentifier == "mc.spaces.list" then
                        local mc_spaces_list = element
                        for _, mc_space in ipairs(mc_spaces_list) do
                            table.insert(spaces, mc_space)
                        end
                    end
                end
            end
        end
    end

    return spaces
end

local function getSpaceIndex(space_id)
    local layout = hs.spaces.allSpaces()
    local index = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
        local screen_uuid = screen:getUUID()
        for i, space in ipairs(layout[screen_uuid]) do
            if space == space_id then
                return index + i
            end
        end
        index = index + #layout[screen_uuid]
    end

    return nil
end

-- move focused window to new space

function Drag:focusedWindowToSpace(space_id)
    local log = hs.logger.new(self.name)

    local focused_window = hs.window.focusedWindow()
    if not focused_window then
        log.e("no focused window")
        return
    end

    local titlebar = hs.geometry(focused_window:zoomButtonRect()).center
    titlebar.x = titlebar.x + 10 -- click mouse a bit to the right of the button

    mouseMove(titlebar)
    mouseDown(titlebar)

    wait(1)                       -- wait a good bit

    hs.spaces.gotoSpace(space_id) -- switch to new space

    wait(1)                       -- wait a good more bit

    mouseUp(titlebar)
end

return Drag
