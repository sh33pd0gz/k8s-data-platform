# Kubernetes Data Platform

### Infrastructure

- k8s/k3s cluster

    * colima k3s (local)
    * GCP GKE (cloud)

- operators:

    * cert-manager
    * flink-kubernetes-operator
    * strimzi-kafka-operator
    * seaweedfs-operator (object storage)
    * kube-prometheus-stack 

- manifests:

    * `kafka-single-node.yaml`
    * `flink-session-deployment.yaml`

### Deployment

```bash
# from within the `terraform` directory
terraform init
terraform apply

# from within the `manifests` directory
kubectl apply -f kafka-single-node.yaml
kubectl apply -f flink-session-deployment.yaml
```

### Useful CLI Commands

_produce random messages to kafka cluster_

```bash
kubectl -n kafka exec -i kafka-cluster-dual-role-0 -c kafka -- \
    bin/kafka-producer-perf-test.sh --topic my-topic --num-records 1000000 --record-size 100 --throughput 100 --producer-props bootstrap.servers=kafka-cluster-kafka-bootstrap:9092 --print-metrics
```

