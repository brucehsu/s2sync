#!/bin/sh
jrake rawr:clean
jrake rawr:jar
jrake rawr:bundle:exe
cp -R lib/swt/swt_win*.jar package/windows/lib/java
cd package/windows/
zip -r s2sync_app-win32.zip  s2sync_app.exe  lib
