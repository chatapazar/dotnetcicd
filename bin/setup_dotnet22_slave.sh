  
#!/bin/sh
PROJECT=ci-cd
JENKINS_SLAVE=dotnet22-with-tools
echo "################  ${JENKINS_SLAVE} ##################"
oc new-build --strategy=docker -D $'FROM registry.access.redhat.com/dotnet/dotnet-22-jenkins-slave-rhel7:latest\n
   USER 1001' --name=${JENKINS_SLAVE} -n ${PROJECT}
echo "Wait 5 sec for build to start"
sleep 5
oc logs build/${JENKINS_SLAVE}-1 -f -n ${PROJECT}
oc get build/${JENKINS_SLAVE}-1 -n ${PROJECT}
