resource "helm_release" "gitlab-operator" {
  name = "gitlab-operator"

  repository = "https://gitlab.com/api/v4/projects/18899486/packages/helm/stable"
  chart = "gitlab-operator"

  namespace = "gitlab-system"
  create_namespace = true
  wait = true
  wait_for_jobs = true

  set {
    name = "gitlab.gitaly.persistence.size"
    value = "10Gi"
  }

  depends_on = [
    helm_release.cert-manager
  ]
}

variable "aws_access_key_id" {
  type = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab"
  }
}

resource "kubernetes_secret" "gitlab-wasabi-secret" {
  metadata {
    name = "gitlab-wasabi-secret"
    namespace = "gitlab"
  }

  data = {
    connection = yamlencode({
      "provider" = "AWS"
      "region" = "us-west-1"
      "endpoint" = "s3.us-west-1.wasabisys.com"
      "aws_access_key_id" = var.aws_access_key_id
      "aws_secret_access_key" = var.aws_secret_access_key
    })
    config = <<INI
    [default]
    access_key = ${var.aws_access_key_id}
    secret_key = ${var.aws_secret_access_key}

    bucket_location = us-west-1
    host_base = s3.us-west-1.wasabisys.com
    INI
  }

  depends_on = [
    kubernetes_namespace.gitlab
  ]
}

resource "kubectl_manifest" "gitlab" {
  yaml_body = <<YAML
apiVersion: apps.gitlab.com/v1beta1
kind: GitLab
metadata:
  name: gitlab
  namespace: gitlab-system
spec:
  chart:
    version: 7.2.4
    values:
      global:
        hosts:
          domain: gitlab.expidusos.com
        ingress:
          configureCertmanager: true
        minio:
          enabled: false
        appConfig:
          lfs:
            bucket: expidusos-gitlab-lfs-us-west-1
          artifacts:
            bucket: expidusos-gitlab-artifacts-us-west-1
          uploads:
            bucket: expidusos-gitlab-uploads-us-west-1
          packages:
            bucket: expidusos-gitlab-packages-us-west-1
          backups:
            bucket: expidusos-gitlab-backups-us-west-1
          object_store:
            connection:
              secret: gitlab-wasabi-secret
              key: connection
      certmanager-issuer:
        email: inquiry@midstall.com
      gitlab:
        toolbox:
          backups:
            objectStorage:
              config:
                secret: gitlab-wasabi-secret
                key: config
YAML

  depends_on = [
    kubernetes_secret.gitlab-wasabi-secret,
    helm_release.gitlab-operator
  ]
}
