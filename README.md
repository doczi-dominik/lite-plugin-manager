# lite Plugin Manager

A simple plugin manager for the (*lite* text editor)[https://github.com/rxi/lite]. Specifically designed for use with the *Project Module* feature of lite, it enables you to only load certain projects instead of all plugins inside the plugins folder.

## Installation

### 1. Download the `plugin_manager.lua` file

You can use `git clone https://github.com/doczi-dominik/lite-plugin-manager` or use `wget` to download the raw file.
<br /><br />
### 2. Move the file to your `data/plugins` directory in your *lite* installation path.
<br />

##### 2a. Modify the list of enabled plugins in the downloaded file.

By default, all plugins that are shipped with *lite* are enabled, except the language plugins.
<br /><br />
### 3. Modify `data/core/init.lua` to disable the built-in plugin loading.

Search for the line 
```lua
local got_plugin_error = not core.load_plugins()
```

and change it to

```lua
local got_plugin_error = false
```

You can also delete or comment out the `core.load_plugins()` function.

## Global usage

#### Open your *User Module* (`data/user/init.lua`) and make sure to source the manager like this:
```lua
local plugin_m = require "plugins.plugin_manager"
```
This will initialize the plugin list with the values set in the lua file. 

#### To add more plugins to the list:

```lua
plugin_m.enable("plugin1")
plugin_m.enable("plugin2")

-- OR

plugin_m.enable({
  "plugin1",
  "plugin2"
})
```

#### To remove existing plugins from the list:

```lua
plugin_m.disable("plugin3")
plugin_m.disable("plugin4")

-- OR

plugin_m.disable({
  "plugin3",
  "plugin4"
})
```

#### To override the list of enabled plugins:

```lua
plugin_m.enabled = {
  "plugin5",
  "plugin6",
  "plugin7"
}
```

Provide plugin names without the `.lua` extension and the plugins folder prefix. For example, to access `data/plugins/languages_sh.lua`, simply use `languages_sh`.

#### Finally, load the enabled plugins:

```lua
plugin_m.load_plugins()
```

## Per-project usage

If a directory contains a `.lite_project.lua` file, *lite* executes it after the *User Module*. This is where the manager shines the most, as you can use language and/or project-specific plugins instead of having to load the Golang, Lua and C++ modules for your shell scripts folder.

#### First, create a `.lite_project.lua` file

You can do this manually, or use the *Command Finder* and select `Core: Open Project Module`.

### Source the manager, and use it as previously:

```lua
local plugin_m = require "plugins.plugin_m"

plugin_m.disable("language_lua")

plugin_m.enable({
  "golang",
  "gofmt"
})

plugin_m.load_plugins()
```

## On-the-fly usage

You can also use project manager to inject plugins while in the editor. To do so, open the *Command Finder* and select `Plugin Manager: Inject Plugin`. Type you want to load in the menu that pops up.

Furthermore, you can inject all plugins (enabled or disabled) by using `Plugin Manager: Inject All Plugins` in the *Command Finder*


