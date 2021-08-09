#Helm install of sample app on IKS
data "terraform_remote_state" "iksws" {
  backend = "remote"
  config = {
    organization = "cisco-intersight-demo"
    workspaces = {
      name = var.ikswsname 
    }
  }
}

variable "ikswsname" {
  type = string
}

resource helm_release iwok8scollector {
  name       = "iwok8scollector"
  namespace = "default"
#  namespace = "iwo-collector"
  chart = "http://100.64.0.15/iwo-k8s-collector-v1.0.1.tgz"

  set {
    name  = "iwoServerVersion"
    value = "8.0"
  }
  set {
    name  = "collectorImage.tag"
    value = "8.0.6"
  }
  set {
    name  = "targetName"
    value = "sbcluster"
  }
}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
    client_key = base64decode(local.kube_config.users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  }
}

locals {
  kube_config = yamldecode(data.terraform_remote_state.iksws.outputs.kube_config)
}


