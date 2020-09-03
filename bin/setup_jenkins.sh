#!/bin/sh
START_BUILD=$(date +%s)
export CICD_PROJECT=ci-cd
JENKINS_PVC_SIZE="4Gi"
function check_pod(){
    sleep 15
    READY="NO"
    while [ $READY = "NO" ];
    do
        clear
        echo "Wait for $1 pod to sucessfully start"
        MESSAGE=$(oc get pods  -n ${CICD_PROJECT}| grep $1 | grep -v deploy)
        STATUS=$(echo ${MESSAGE}| awk '{print $2}')
        if [ $(echo -n ${MESSAGE} | wc -c) -gt 0 ];
            then
            if [ ${STATUS} = "1/1" ];
            then
                READY="YES"
            else 
                echo "Current Status: ${MESSAGE}"
                cat $1.txt
                sleep 3
                clear
                echo "Current Status: ${MESSAGE}"
                cat wait.txt
                sleep 2

            fi
        else
            oc get pods -n ${CICD_PROJECT} | grep $1
            sleep 5
        fi
    done
}
oc project ${CICD_PROJECT}
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi \
--param VOLUME_CAPACITY=${JENKINS_PVC_SIZE} --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc set resources dc jenkins --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m
oc label dc jenkins app.kubernetes.io/name=Jenkins -n ${CICD_PROJECT}
# No need to wait for jenkins to start
check_pod "jenkins"
echo "Wait 10 sec..."
sleep 10
END_BUILD=$(date +%s)
BUILD_TIME=$(expr ${END_BUILD} - ${START_BUILD})
clear
echo "Jenkins URL = $(oc get route jenkins -n ${CICD_PROJECT} -o jsonpath='{.spec.host}')"
echo "Elasped time to build is $(expr ${BUILD_TIME} / 60 ) minutes"
