#!/bin/sh
oc autoscale dc/dotnetapp --min 1 --max 10 --cpu-percent=50


apiVersion: autoscaling/v2beta2 
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-autoscale 
  namespace: demo-dev31
spec:
  scaleTargetRef:
    apiVersion: v1 
    kind: DeploymentConfig 
    name: dotnetapp 
  minReplicas: 1 
  maxReplicas: 10 
  metrics: 
  - type: Resource
    resource:
      name: cpu 
      target:
        type: Utilization 
        averageValue: 500m 
