
![Panels](http://jaliborc.com/images/addons/large/wowunit.jpg)

# WoWUnit :microscope:

[![Install](http://img.shields.io/badge/install-curseforge-484266)](https://www.curseforge.com/wow/addons/wowunit/files)
[![Patreon](http://img.shields.io/badge/donate-patreon-ff4d42)](https://www.patreon.com/jaliborc)

WoWUnit allows you to easily write unit tests for your World of Warcraft addons and provides an interface to monitor them. Unit tests can be run at game events. Also provides methods for temporarily mocking variables.

## Example
Let's assume we define the following functions in our addon:

    Numbers = function() return 1, 2, 3 end
    Realm = function() GetRealmName() .. '!' end

We can make the following tests:

    local AreEqual, Exists, Replace = WoWUnit.AreEqual, WoWUnit.Exists, WoWUnit.Replace
    local Tests = WoWUnit('MyAddonName', 'PLAYER_UPDATE', 'MONEY_UPDATE')
        -- tests will be called at startup, PLAYER_UPDATE and MONEY_UPDATE events

    function Tests:PassingTest()
        AreEqual({1,2,3}, {Numbers()})
        Exists(true)
    end

    function Tests:FaillingTest()
        AreEqual('Apple', 'Pie')
        Exists(false)
    end

    function Tests:MockingTest()
        Replace('GetRealmName', function() return 'Horseshoe' end)
        AreEqual('Horseshoe!', Realm())
    end


## Test API
A unit test group is created by calling `WoWUnit(name, event1, event2, ...)` or `WoWUnit:NewGroup(name, event1, event2, ...)`.
Unit tests in the group are called at startup and whenever the game events listed occur.

A unit test is defined by indexing a function in the group. While the test is running, the following methods can be used:

|Name|Description|
|:--|:--|
| AreEqual(a, b) | Checks wether `a` and `b` match. Throws a fail status if not. |
| IsTrue(value) | Checks wether `value` passes an if statement. Throws a fail status if not. |
| Exists(value) | Same as above. |
| IsFalse(value) | Checks wether `value` fails an if statement. Throws a fail status if not. |
| Replace([table,] name, replace) | Temporarly replaces `table[name]` or global `name` with `replace` while the unit test is running. |
| ClearReplaces() | Resets all replacements done so far. |
| Enable() | Enables the current unit test (enabled by default). |
| Disable() | Disables the current unit test. |
