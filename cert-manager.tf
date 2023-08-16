resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  namespace = "cert-manager"
  create_namespace = true

  atomic = true
  cleanup_on_fail = true
  recreate_pods = true
  verify = false

  set {
    name = "installCRDs"
    value = "true"
  }
}
