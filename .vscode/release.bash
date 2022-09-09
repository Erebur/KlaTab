#!/bin/bash

site="/home/erebur/Programmieren/Gits/erebur.github.io"
this="/home/erebur/Programmieren/Gits/klatab"
name=klatab

cd $this
flutter build apk
flutter build web

cd $site
git pull
mkdir  $site/$name

cp $this/build/app/outputs/flutter-apk/app-release.apk $site/releases/$name.apk
cp -r $this/build/web/*  $site/$name/
git add * 
git commit -a -m "update"
git push 