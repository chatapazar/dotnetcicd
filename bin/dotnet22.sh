#!/bin/sh
oc new-project dotnet22 --display-name="dotnet22"

oc policy add-role-to-group system:image-puller system:serviceaccounts:dotnet22 -n ci-cd

oc policy add-role-to-user edit system:serviceaccount:ci-cd:jenkins -n dotnet22

oc new-app -n dotnet22 --allow-missing-imagestream-tags=true -f https://raw.githubusercontent.com/chengkuangan/dotnetsample/master/templates/dotnet-template.yaml -p IMAGE_PROJECT_NAME=dotnet22 -p IMAGE_TAG=latest -p APPLICATION_NAME=sampledotnet22
