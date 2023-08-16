resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.bitnami.com/bitnami"
  chart = "cert-manager"

  namespace = "cert-manager"
}
