#!/usr/bin/env bash

zip -9 -r PortalPush.love .love-file main.lua conf.lua lib/ assets/
cat /usr/bin/love PortalPush.love > PortalPush
chmod u+x ./PortalPush
