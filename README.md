This is a bunch of utilities allowing for some functionality in the Morrowind Script Extender.

## Package Manager

Firstly, this mod contains a utility which allows for dynamic reloading of packages without having to restart the game.

You can easily hook in to this functionality with two fairly easy steps:
* A `require("darkcraft.dev.package_manager.import")` at the top of your main.lua file, to make sure the import code is loaded before you start doing work.
* Replace your `require("...")` code with `import("...")` to use the package_manager import code

This works by making every access to the imported module call the require method. This has negligible performance issues because the require method caches everything, until the package manager clears it, at which point the next call will load the updated version of your file.

### Caveats
* Any error which happens *while* a file is being loaded (i.e. before the return method calls) will result in that module not being able to be cleared correctly, requiring a restart.
* A very negligible performance hit is accrued by using this.

## UI

Secondly, this mod contains a framework based heavily on ReactJS which allows you to create Morrowind UIs in an XML style format.

This includes having changes to the data object automatically propogating and changing the relevant UI elements.