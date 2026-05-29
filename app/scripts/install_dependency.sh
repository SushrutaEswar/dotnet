#!/bin/bash

sudo yum update -y

sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

sudo yum install -y dotnet-sdk-8.0