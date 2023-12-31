resource "helm_release" "external-dns" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "external-dns"

  namespace = "external-dns"
  name = "external-dns"
  create_namespace = true

  set {
    name = "provider"
    value = "cloudflare"
  }

  set {
    name = "cloudflare.apiToken"
    value = var.cloudflare_token
  }

  set {
    name = "cloudflare.apiKey"
    value = var.cloudflare_key
  }

  set {
    name = "cloudflare.email"
    value = "rosscomputerguy@protonmail.com"
  }

  depends_on = [
    resource.google_container_node_pool.infra-primary-nodes
  ]
}

variable "cloudflare_token" {
  type = string
  sensitive = true
}

variable "cloudflare_key" {
  type = string
  sensitive = true
}
