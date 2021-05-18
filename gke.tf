## 2.2. GKE module
# module "gke" {
#   source     = "./modules/gke"
#   project_id = data.google_project.this.id
#   region     = var.region
#   prefix     = local.prefix
#   vpc_subnet = google_compute_subnetwork.gke.self_link
# }

## 2.3. Descomentar este output apenas no passo 2.3
# output "gke_kubeconfig" {
#   value = module.gke.gke_kubeconfig
# }


## 3.2 Criar e testar um ingress
# data "template_file" "hipster_ingress" {
#   template = file("./templates/hipster-ingress-template.yaml")

#   vars = {
#     fqdn = trimsuffix(module.dns.fqdn,".")
#   }
# }

# resource "local_file" "hipster_ingress" {
#   content  = data.template_file.hipster_ingress.rendered
#   filename = "./k8s/hipster-demo/300-frontend-ingress.yaml"
# }
