-- Standard awesome library
-- this is my test
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Debian menu entries
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

-- Private naughty config
--naughty.config.default_preset.font             = "sans 13.5"
naughty.config.default_preset.font             = "WenQuanYi Micro Hei 10"
naughty.config.default_preset.position         = "bottom_right"
naughty.config.default_preset.fg               = beautiful.fg_focus
naughty.config.default_preset.bg               = beautiful.bg_focus
naughty.config.default_preset.border_color     = beautiful.border_focus

-- This is used later as the default terminal and editor to run.
-- terminal = "xterm"
terminal = "gnome-terminal"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor
pidgin_flag = 0

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

--
-- {{{ Wibox
-- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" })
mytextclock = awful.widget.textclock({ align = "right" }, '<span color="lightblue">\t%A</span><span color="lightgreen"> %B %d, %Y </span><span color="red">(week %W, day %j) </span><span color="cyan">%H:%M:%S</span>', 1)


mynetwork = widget({ type = "textbox", align = "right" })
mynetwork.text = "  ?  "

-- Create a systray
mysystray = widget({ type = "systray" })

-- Private decoration
myicon = widget({ type = "imagebox" })
myicon.image = image(beautiful.awesome_icon)
myspace = widget({ type = "textbox" })
myspace.text = "  "

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "20",screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            myspace,
            mylayoutbox[s],
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mytextclock,
        s == 1 and mysystray or nil,
        mynetwork,
        --datewidget, 
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
--awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
--awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

    -- {{{ sdcv/stardict
    awful.key({ modkey }, "d", function ()
        local f = io.popen("xsel -o")
        local new_word = f:read("*a")
        f:close()

        if frame ~= nil then
            naughty.destroy(frame)
            frame = nil
            if old_word == new_word then
                return
            end
        end
        old_word = new_word

        local fc = ""
        local f  = io.popen("sdcv -n --utf8-output "..new_word)
        for line in f:lines() do
            fc = fc .. line .. '\n'
        end
        f:close()
        frame = naughty.notify({ text = fc, timeout = 10, width = 320 })
    end),
    awful.key({ modkey, "Shift" }, "d", function ()
        awful.prompt.run({prompt = "Dict: "}, mypromptbox[mouse.screen].widget, function(cin_word)
            naughty.destroy(frame)
            if cin_word == "" then
                return
            end

            local fc = ""
            local f  = io.popen("sdcv -n --utf8-output "..cin_word)
            for line in f:lines() do
                fc = fc .. line .. '\n'
            end
            f:close()
            frame = naughty.notify({ text = fc, timeout = 10, width = 320 })
        end, nil, awful.util.getdir("cache").."/dict")
    end),
    -- }}}

    awful.key({ modkey, }, ",", function () movetocurrent("Pidgin") end),
    awful.key({ modkey,           }, "p",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "n",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "r", function () mypromptbox[mouse.screen]:run() end),
    --awful.key({ modkey,           }, "r", function ()  awful.util.spawn_with_shell( "exe=`dmenu_path | dmenu -b -nf '#888888' -nb '#222222' -sf '#ffffff' -sb '#285577'` && exec $exe")end),
    --[[
    awful.key({ modkey },            "r",     function ()
        awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" .. 
        beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. 
        "' -sb '" .. beautiful.bg_focus .. 
        "' -sf '" .. beautiful.fg_focus .. "'") 
    end),
    ]]
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "i",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "o",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.client.incwfact( 0.05)   end),
    awful.key({ modkey,           }, "l",     function () awful.client.incwfact(-0.05)   end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Private global keys
    awful.key({ modkey, }, "a", function () awful.util.spawn("xterm -e alsamixer") end),
    awful.key({ modkey, }, "b", function () mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible end),
    --awful.key({ modkey, }, "i", function () awful.util.spawn("iceweasel") end),
    --awful.key({ modkey, }, "c", function () awful.util.spawn_with_shell("exe=`export LD_PRELOAD=/usr/lib/libGL.so && chromium-browser`") end),
    awful.key({ modkey, }, "c", function() launch_browser() end),
    awful.key({ modkey, }, "u", function() launch_Mendeleydesktop() end),
    --awful.key({ modkey, }, "e", function () launch_nautilus() end),
    awful.key({ modkey, }, "e", function () launch_nautilus() end),
    awful.key({ modkey, "Shift"}, "e", function () awful.util.spawn("rox-filer") end),

    --awful.key({ modkey, }, "m", function () awful.util.spawn("amixer -q sset Master toggle") end),
    --awful.key({ modkey, }, "p", function () awful.util.spawn("pidgin") end),
    --awful.key({ modkey, }, "s", function () awful.util.spawn("xlock -mode blank -dpmsoff 5 -font -misc-fixed-*-*-*-*-20-*-*-*-*-*-*") end),
    awful.key({ modkey, }, "s", function () awful.util.spawn("gnome-screensaver-command --lock") end),
    awful.key({ modkey, }, "t", function () awful.util.spawn("mpc toggle") end),
    awful.key({ modkey, }, "v", function () launch_virtualbox() end),
    awful.key({ modkey, }, "x", function () awful.util.spawn("xterm") end),
    awful.key({ modkey, }, "Up", function () awful.util.spawn("amixer -q sset PCM 10%+ unmute") end),
    awful.key({ modkey, }, "Down", function () awful.util.spawn("amixer -q sset PCM 10%- unmute") end),
    awful.key({ "Mod1" }, "F2", function () awful.util.spawn("gmrun") end),
    awful.key({ "Mod1" }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({}, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/Pictures/Shot/'") end),
    awful.key({}, "XF86AudioPlay", function () awful.util.spawn("mpc toggle") end),
    awful.key({}, "XF86AudioStop", function () awful.util.spawn("mpc stop") end),
    awful.key({}, "XF86AudioPrev", function () awful.util.spawn("mpc prev") end),
    awful.key({}, "XF86AudioNext", function () awful.util.spawn("mpc next") end),
    awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer -q sset Master toggle") end),
    awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q sset PCM 10%- unmute") end),
    awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q sset PCM 10%+ unmute") end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Control" }, "n",      function (c) c.minimized = not c.minimized    end),

    -- unminimize windows
    awful.key({ modkey, "Shift"   }, "n",
    function ()
        local allclients = client.get(mouse.screen)

        for _,c in ipairs(allclients) do
            if c.minimized and c:tags()[mouse.screen] ==
                awful.tag.selected(mouse.screen) then
                c.minimized = false
                client.focus = c
                c:raise()
                return
            end
        end
    end),

    --[[
    awful.key({ modkey, "Control" }, "n", 
        function()
            local tag = awful.tag.selected()
                for i=1, #tag:clients() do
                    tag:clients()[i].minimized=false
                    tag:clients()[i]:redraw()
            end
        end),
        ]]

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    -- Private client keys
    awful.key({ "Mod1" }, "F3",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    awful.key({ "Mod1" }, "F4", function (c) c:kill() end),
    awful.key({ modkey, "Control" }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey, "Control" }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey, "Control" }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey, "Control" }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey, "Control" }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey, "Control" }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end)

)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey }, "0",
                  function ()
                        local screen = mouse.screen
                        awful.tag.viewmore(tags[screen])
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    -- Private rules
    { rule = { },
      properties = { size_hints_honor = false } },
    { rule = { class = "Gimp" },
      properties = { floating = true, tag = tags[1][7] } },
    { rule = { class = "Gmrun" },
      properties = { floating = true } },
--    { rule = { class = "Iceweasel" },
--      properties = { tag = tags[1][2] } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },

    { rule = { class = "Openfetion" },
      properties = { floating = true, tag = tags[1][8] } },
    { rule = { class = "Pidgin" },
      properties = { floating = true} },
    { rule = { class = "Skype" },
      properties = { floating = true, tag = tags[1][8] } },
    { rule = { class = "Linux-fetion" },
      properties = { floating = true, tag = tags[1][8] } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][9] } },
    { rule = { class = "Chromium-browser"},
      properties = { tag = tags[1][6] } },
    { rule = { class = "Nautilus"},
      properties = { tag = tags[1][3] } },
    { rule = { class = "Krusader"},
      properties = { floating = true, tag = tags[1][3] } },
    { rule = { class = "Thunar"},
      properties = { tag = tags[1][3] } },
    { rule = { class = "Mendeleydesktop"},
      properties = { tag = tags[1][7] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- Focus
client.add_signal("focus"   , function(c)
                                 c.border_color = beautiful.border_focus
                                 c.opacity = 1
                              end)

-- Unfocus
client.add_signal("unfocus" , function(c)
                                 c.border_color = beautiful.border_normal
                                 c.opacity = 0.75
                              end)
--client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--apptags =
--{
--    ["smplayer"] = { screen = 1, tag = 7 },
--    ["chromium-browser"] = { screen = 1, tag = 6 },
--    ["Firefox"] = { screen = 1, tag = 6},
--    ["VirtualBox"] = { screen = 1, tag = 9 },
--    ["Linux-fetion"] = { screen = 1, tag = 7 },
--}
--
-- Autorun programs
autorun = true
autorunApps = 
{ 
    "pastie",
    "pidgin",
    "gnome-do",
    "indicator-weather",
}

function launch_browser()
    local ret1 = os.execute("pgrep chrom")
    local ret2 = os.execute("pgrep firefox")
    local ret3 = os.execute("pgrep opera")
    if ret1 ~= 0 and ret2 ~= 0  and ret3 ~= 0 then
        awful.util.spawn_with_shell("x-www-browser")
    end
    awful.tag.viewonly(tags[1][6])
end

function launch_Mendeleydesktop()
    local ret = os.execute("pgrep mendeleydesktop")
    if ret ~= 0 then
        awful.util.spawn("mendeleydesktop")
    end
    awful.tag.viewonly(tags[1][7])
end

function launch_nautilus()
    local ret = os.execute("pgrep -x nautilus")
    if ret ~= 0 then
        awful.util.spawn("nautilus")
    end
    awful.tag.viewonly(tags[1][3])
end

function launch_thunar()
    local ret = os.execute("pgrep -x thunar ")
    if ret ~= 0 then
        awful.util.spawn("thunar")
    end
    awful.tag.viewonly(tags[1][3])
end

function launch_virtualbox()
    local ret = os.execute("pgrep -x VirtualBox ")
    if ret ~= 0 then
        awful.util.spawn("virtualbox")
    end
    awful.tag.viewonly(tags[1][9])
end

if autorun then
    for app = 1, #autorunApps do
        local ret = os.execute("pgrep -x " .. autorunApps[app])
        if ret ~= 0 then
            awful.util.spawn(autorunApps[app])
        end
    end
    awful.util.spawn("/home/b312/.dropbox-dist/dropbox start")
    awful.util.spawn("fcitx -d")
    launch_browser()
end

function run_once(command)
    if not command then
        do return nil end
    end
    local program = command:match("[^ ]+")

    -- If program is not running
    if math.fmod(os.execute("pgrep -x " .. program),255) == 1 then
        awful.util.spawn(command)
    end
end

--my hook
function hook_manage(c)
    if c.name:find("mplayer") then
        c.floating = true
    end
end
awful.hooks.focus.register(hook_manage)
awful.hooks.timer.register(2, function() mynetwork.text = '<span color="yellow">\t' .. getnetworkinfo() .. '\t</span>' end)

function getnetworkinfo()
    --config_dir = awful.util.getdir("config")
    local f = io.open("/tmp/networkinfo") 
    local l = nil
    if f ~= nil then
       l = f:read()
    else
       l = " ? "
    end
    f:close()
    os.execute( "/tmp/sysmon > /tmp/networkinfo &" )
    return l
end

function movetocurrent(name)
   local clients = client.get(1)
   local curtag = awful.tag.selected()
   --os.execute( "echo searching> /tmp/networkinfo &" )
   for i, c in pairs(clients) do
       --os.execute( "echo " .. c.class .. " >> /tmp/networkinfo &" )
       if c.class:find(name) then
         --os.execute( "echo find> /tmp/networkinfo &" )
         if pidgin_flag == 0 then
             pidgin_flag = 1
             awful.client.movetotag(curtag, c)
         else
             pidgin_flag = 0
             awful.client.movetotag(tags[1][8], c)
         end
      end
   end
end

