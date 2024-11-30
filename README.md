# Drag.spoon
Drag a window to a new space in Mission Control. This Spoon is a workaround for [hs.spaces.moveWindowToSpace()](https://www.hammerspoon.org/docs/hs.spaces.html#moveWindowToSpace) not working in MacOS 15 Sequoia.

Inspired by [Stephan Casas](https://github.com/stephancasas/stephan-hates-osascript/blob/main/jxa/move-window-to-desktop.jxa.js) and the Hammerspoon [spaces module](https://github.com/Hammerspoon/hammerspoon/tree/master/extensions/spaces).

Tested with MacOS 14 and 15.

## Usage

Load the Spoon and call the `Drag:focusedWindowToSpace(space_id)` method.
```lua
Drag = loadSpoon("Drag")

-- figure out the space_id for the target space
-- > hs.spaces.allSpaces()
-- {
--   ["1E4625E7-5C5E-4DDC-B4C7-991CCCEF0732"] = { 1301 },
--   ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 528, 2, 1306 }
-- }
-- eg. 1306 is the third space on the second screen

Drag:focusedWindowToSpace(1306)
```

## How it works

Mission Control is actually a full screen application. The Mission Control windows are buttons with a screen shot of each window as the image and the title of each window as the label. The spaces are also buttons with labels "Desktop 1", etc. Using the Accessibility API, we collect all of the space button UI elements and the window button UI elements. We find the desired window button by matching the label to the window's title and use the mouse to drag it to the desired space.

## Limitations

- The window must be visible on the active space of the active screen, so we can drag it with the mouse. The current focused window satisfies these requirements.
- The window must have a unique title. If two windows have the same title, there's no guarantee for which one will be found first.
- The delays between mouse events may need to be tuned depending on the computer and MacOS animation speed.
