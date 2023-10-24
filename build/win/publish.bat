for /f "delims== tokens=1,2" %%G in (cloud-ids.txt) do set %%G=%%H
set /p key=<"api-key.txt"
rbxcloud experience publish --filename doomball.rbxl --version-type saved --place-id %place-id% --universe-id %universe-id% --api-key %key%
explorer roblox-studio://launchmode/:edit+task:EditPlace+placeId:%place-id%+universeId:%universe-id%