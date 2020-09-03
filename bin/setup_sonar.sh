#!/bin/sh
START_BUILD=$(date +%s)
export CICD_PROJECT=ci-cd
SONAR_PVC_SIZE="4Gi"
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
oc new-app --template=postgresql-persistent \
--param POSTGRESQL_USER=sonar \
--param POSTGRESQL_PASSWORD=sonar \
--param POSTGRESQL_DATABASE=sonar \
--param VOLUME_CAPACITY=${SONAR_PVC_SIZE} \
--labels=app=sonarqube_db
check_pod "postgresql"
oc new-app --docker-image=quay.io/gpte-devops-automation/sonarqube:7.9.1 --env=SONARQUBE_JDBC_USERNAME=sonar --env=SONARQUBE_JDBC_PASSWORD=sonar --env=SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar --labels=app=sonarqube
oc rollout pause dc sonarqube
oc label dc sonarqube app.kubernetes.io/part-of=Code-Quality -n ${CICD_PROJECT}
oc expose svc sonarqube
oc create route edge sonarqube --service=sonarqube --port=9000
oc set volume dc/sonarqube --add --overwrite --name=sonarqube-volume-1 --mount-path=/opt/sonarqube/data/ --type persistentVolumeClaim --claim-name=sonarqube-pvc --claim-size=1Gi
oc set resources dc sonarqube --limits=memory=2Gi,cpu=1 --requests=memory=1Gi,cpu=0.5
oc patch dc sonarqube --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 --get-url=http://:9000/about
oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about
oc patch dc/sonarqube --type=merge -p '{"spec": {"template": {"metadata": {"labels": {"tuned.openshift.io/elasticsearch": "true"}}}}}'
oc label dc postgresql app.kubernetes.io/part-of=Code-Quality -n ${CICD_PROJECT}
oc label dc postgresql app.kubernetes.io/name=posgresql -n ${CICD_PROJECT}
oc rollout resume dc sonarqube
check_pod "sonarqube"
echo "Wait 10 sec..."
sleep 10
END_BUILD=$(date +%s)
BUILD_TIME=$(expr ${END_BUILD} - ${START_BUILD})
clear
echo "Elasped time to build is $(expr ${BUILD_TIME} / 60 ) minutes"
