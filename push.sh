#!/bin/bash
msg=$1
echo $1
git add .
git commit -m $1
git push origin master