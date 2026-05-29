#!/bin/bash

cd /home/ec2-user/app

nohup dotnet DotNetMinimalAPI.dll > app.log 2>&1 &