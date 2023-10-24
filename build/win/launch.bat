for /f "delims== tokens=1,2" %%G in (cloud-ids.txt) do set %%G=%%H
explorer roblox-studio://launchmode/:edit+task:EditPlace+placeId:%place-id%+universeId:%universe-id%
exit 0