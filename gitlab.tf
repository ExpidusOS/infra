resource "helm_release" "gitlab-operator" {
  name = "gitlab-operator"

  repository = "https://gitlab.com/api/v4/projects/18899486/packages/helm/stable"
  chart = "gitlab-operator"

  namespace = "gitlab-system"
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
    "provider" = "AWS"
    "region" = "us-west-1"
    "endpoint" = "expidusos-gitlab-us-west-1.s3.wasabisys.com"
    "aws_access_key_id" = var.aws_access_key_id
    "aws_secret_access_key" = var.aws_secret_access_key
  }

  depends_on = [
    kubernetes_namespace.gitlab
  ]
}

resource "kubernetes_manifest" "gitlab" {
  manifest = {
    "apiVersion" = "apps.gitlab.com/v1beta1"
    "kind" = "GitLab"
    "metadata" = {
      "name" = "gitlab"
      "namespace" = "gitlab-system"
    }
    "spec" = {
      "chart" = {
        "version" = "7.2.4"
        "values" = {
          "global" = {
            "hosts" = {
              "domain" = "gitlab.expidusos.com"
            }
            "ingress" = {
              "configureCertmanager" = true
            }
            "minio" = {
              "enabled" = false
            }
            "appConfig" = {
              "object_store" = {
                "enabled" = true
                "connection" = {
                  "secret" = "gitlab-wasabi-secret"
                }
              }
            }
          }
          "certmanager-issuer" = {
            "email" = "inquiry@midstall.com"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_secret.gitlab-wasabi-secret,
    helm_release.gitlab-operator
  ]

  wait = {
    fields = {
      "status.conditions[0].status" = "True",
    } 
  }
}
