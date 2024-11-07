#!/bin/bash
helm upgrade prometheus prometheus-community/prometheus --set server.persistentVolume.enabled=true --set server.persistentVolume.storageClass=longhorn --set server.persistentVolume.existingClaim=prom-pvc 

helm upgrade grafana grafana/grafana --set persistence.enabled=true,persistence.storageClassName="longhorn",persistence.existingClaim="grafana-pvc" 