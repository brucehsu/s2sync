#!/bin/sh
jrake rawr:clean
jrake rawr:jar
jrake rawr:bundle:app
cp Info.plist.new package/osx/s2sync_app.app/Contents/Info.plist
cp `pwd`/lib/swt/swt_mac* package/osx/s2sync_app.app/Contents/Resources/Java/lib/java