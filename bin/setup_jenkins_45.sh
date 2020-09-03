#!/bin/sh
oc project ci-cd
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=4Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc set resources dc jenkins --limits=memory=4Gi,cpu=2 --requests=memory=1Gi,cpu=1
oc label dc jenkins app.kubernetes.io/name=Jenkins -n ci-cd
