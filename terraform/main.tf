resource "terraform_data" "colima_provisioner" {
  triggers_replace = [
    var.colima_profile,
    var.cpu_cores,
    var.memory_gb,
    var.disk_gb
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # 1. Gracefully shut down if already running to apply new CPU/RAM specs
      if colima status ${var.colima_profile} >/dev/null 2>&1; then
        echo "Stopping active Colima instance to re-allocate hardware..."
        colima stop ${var.colima_profile}
      fi
      # 2. Build flags dynamically based on variables
      FLAGS="--cpu ${var.cpu_cores} --memory ${var.memory_gb} --disk ${var.disk_gb}"

      # 3. Spin up Colima with the new target spec configuration
      echo "Launching Colima with parameters: $FLAGS"
      colima start ${var.colima_profile} $FLAGS --kubernetes --vm-type vz --vz-rosetta

      # 4. Loop until kubectl can successfully reach the API server
      echo "Waiting for Colima Kubernetes API to become ready..."
      until kubectl cluster-info --context ${var.colima_profile} >/dev/null 2>&1; do
        echo "Cluster is not ready yet. Retrying in 5 seconds..."
        sleep 5
      done
      echo "Kubernetes API is up and running!"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "colima stop ${self.triggers_replace[0]}"
  }
}

# OPERATORS =======================================================================================
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "oci://quay.io/jetstack/charts/cert-manager"
  version          = "v1.21.3"
  create_namespace = true
  namespace        = "cert-manager"
  set = [
    {
      name  = "crds.enabled"
      value = true
    }
  ]
  depends_on = [terraform_data.colima_provisioner]
}

resource "helm_release" "flink_kubernetes_operator" {
  name             = "flink-kubernetes-operator"
  repository       = "https://downloads.apache.org/flink/flink-kubernetes-operator-1.16.1/"
  chart            = "flink-kubernetes-operator"
  version          = "1.16.1"
  create_namespace = true
  namespace        = "flink"
  depends_on = [
    terraform_data.colima_provisioner,
    helm_release.cert_manager
  ]
}

resource "helm_release" "strimzi_kafka_operator" {
  name             = "strimzi-kafka-operator"
  repository       = "https://strimzi.io/charts/"
  chart            = "strimzi-kafka-operator"
  version          = "1.3.0"
  create_namespace = true
  namespace        = "kafka"
  depends_on       = [terraform_data.colima_provisioner]
}

resource "helm_release" "prometheus_operator" {
  name             = "prometheus-operator"
  chart            = "oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack"
  version          = "92.17.0"
  create_namespace = true
  namespace        = "prometheus"

  depends_on = [terraform_data.colima_provisioner]
}

resource "helm_release" "seaweedfs_operator" {
  name             = "seaweedfs-operator"
  repository       = "https://seaweedfs.github.io/seaweedfs-operator/"
  chart            = "seaweedfs-operator"
  version          = "0.1.42"
  create_namespace = true
  namespace        = "seaweedfs"
  depends_on = [
    terraform_data.colima_provisioner,
    helm_release.cert_manager
  ]
}
