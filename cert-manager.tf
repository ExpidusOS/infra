resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  namespace = "cert-manager"
  create_namespace = true

  set {
    name = "installCRDs"
    value = "true"
  }

  depends_on = [
    resource.google_container_node_pool.infra-primary-nodes
  ]
}
