#!/bin/bash

site="/home/erebur/Programmieren/Gits/erebur.github.io"
this="/home/erebur/Programmieren/Gits/klatab"
name=klatab

cd $this
flutter build apk
flutter build web
flutter build linux

cd $site
git pull
mkdir  $site/$name

cp $this/build/app/outputs/flutter-apk/app-release.apk $site/releases/$name.apk
cp -r $this/build/web/*  $site/$name/

cd $this/build/linux/x64/release/bundle/
zip linux.zip *
mv linux.zip $site/releases/

cd $site

git add * 
git commit -a -m "update"
git push 