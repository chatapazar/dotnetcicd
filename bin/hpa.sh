#!/bin/sh
oc autoscale dc/dotnetapp --min 1 --max 10 --cpu-percent=50
