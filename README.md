# Kubernetes Data Platform

## Purpose

This repository is meant to bootstrap data processing tools within a distributed systems
environment. Ultimately, the goal is to explore streaming data from source connectors
_e.g. kafka, filesyste/object storage, etc._ in Apache Flink and use Flink AI, Flink ML,
and the Flink Data Streaming API to process data in unique ways and provide real-time
insights.

## Infrastructure

#### Kubernetes Cluster

    * colima k3s (local)
    * GCP GKE (cloud)

#### Operators (Custom Resource Definitions)

    * cert-manager
    * flink-kubernetes-operator
    * strimzi-kafka-operator
    * seaweedfs-operator (object storage)
    * kube-prometheus-stack

### Useful CLI Commands

_produce random messages to kafka cluster_

```bash
kubectl -n kafka exec -i kafka-cluster-dual-role-0 -c kafka -- \
    bin/kafka-producer-perf-test.sh \
    --topic my-topic --num-records 1000000 --record-size 100 --throughput 100 \
    --producer-props bootstrap.servers=kafka-cluster-kafka-bootstrap:9092 \
    --print-metrics
```

#### Todos

- [ ] diagrams
- [ ] outline Flink setup (session vs deployment)
- [ ] outline monitoring and observability (grafana and prometheus)
