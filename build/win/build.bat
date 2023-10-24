wally install
rojo sourcemap -o sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages
wally-package-types --sourcemap sourcemap.json ServerPackages
rojo build -o doomball.rbxl