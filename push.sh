#!/bin/bash
msg=$1
echo $1
git add .
git commit -m '${msg}'
git push origin master