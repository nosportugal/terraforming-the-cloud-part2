/**
 * # stunner
 *
 * This module installs the [STUNner Helm charts](https://github.com/l7mp/stunner-helm#deploying).
 *
 */

resource "kubernetes_namespace" "stunner" {
  metadata {
    name = "stunner"
  }
}

resource "helm_release" "stunner_gateway_operator" {
  name             = "stunner-gateway-operator"
  repository       = "https://l7mp.io/stunner"
  chart            = "stunner-gateway-operator"
  version          = "0.11.3"
  namespace        = kubernetes_namespace.stunner.metadata[0].name
  wait_for_jobs    = true
  create_namespace = false
}

resource "helm_release" "stunner" {
  name             = "stunner"
  repository       = "https://l7mp.io/stunner"
  chart            = "stunner"
  version          = "0.10.8"
  namespace        = kubernetes_namespace.stunner.metadata[0].name
  wait_for_jobs    = true
  create_namespace = false

  depends_on = [
    helm_release.stunner_gateway_operator
  ]
}

resource "kubectl_manifest" "gateway_class" {
  yaml_body = <<YAML
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: GatewayClass
metadata:
  name: stunner-gatewayclass
spec:
  controllerName: "stunner.l7mp.io/gateway-operator"
  parametersRef:
    group: "stunner.l7mp.io"
    kind: GatewayConfig
    name: stunner-gatewayconfig
    namespace: ${kubernetes_namespace.stunner.metadata[0].name}
  description: "STUNner is a WebRTC ingress gateway for Kubernetes"
YAML

  depends_on = [
    helm_release.stunner_gateway_operator
  ]
}

resource "kubectl_manifest" "gateway_config" {
  yaml_body = <<YAML
apiVersion: stunner.l7mp.io/v1alpha1
kind: GatewayConfig
metadata:
  name: stunner-gatewayconfig
  namespace: ${kubernetes_namespace.stunner.metadata[0].name}
spec:
  realm: stunner.l7mp.io
  authType: plaintext
  userName: "user-1"
  password: "pass-1"
YAML

  depends_on = [
    kubectl_manifest.gateway_class
  ]
}
