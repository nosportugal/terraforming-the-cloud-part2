# terraforming the cloud - part 2

Temas abordados neste modulo:

* Criação de VPCs
* Criação de modulos de Terraform
* Criação de cluster GKE
* Criação de zonas de DNS


## 0. preparar o ambiente

### 0.1 cloud shell

**autenticar a consola com o GCP**
- Abrir o endereço <https://console.cloud.google.com> e autenticar

```bash
gcloud config set project tf-gke-lab-01-np-000001
``` 

**facilitar a leitura dos ficheiros terraform em ambiente cloudshell**
Com o seguinte guia é possivel ajudar um pouco na leitura sintática dos ficheiros terraform usando a formatação `ini`. 

Apesar de não ser ideal, é melhor do que não ter nada e ajuda bastante!

- Com o editor aberto, carregar em `CTRL+,` para abrir as definições
- Procurar por `File Associations` e de seguida `Open settings.json`
- Garantir o seguinte bloco de `files.associations`:
```json
"files.associations": {
    "**/*.tf": "ini"
}
```
### 0.2 VSCode

```bash
gcloud init
gcloud auth application-default login 
``` 

### 0.3 preparar o projeto

**clonar o projecto git que vamos usar**
```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part2 && cd terraforming-the-cloud-part2
```

**obter e instalar a versão do terraform e kubectl que vamos usar**
```bash
# terraform
sudo scripts/install-terraform.sh

# kubectl
sudo scripts/install-kubectl.sh
```

**preparar um prefixo pessoal (pode ser um nome simples sem espaços nem caracteres estranhos**

* No ficheiro [./terraform.tfvars](./terraform.tfvars) é necessário definir um prefixo

```bash
# obrigatório preencher
user_prefix = 
```

**inicializar o terraform**
```bash
# init & plan & apply
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## 1. criar a VPC

* No ficheiro [./vpc.tf](./vpc.tf) encontram-se as definições da VPC a usar

**Descomentar as seguintes resources**

```bash
# vpc
resource "google_compute_network" "default"
```

**Plan & Apply**
```bash
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

*Validar the a VPC foi criada com a respetiva subnet...*
```bash
gcloud compute networks list | grep $(terraform output -raw my_identifier)
```

## 2. Modules & GKE

Neste capitulo iremos usar terraform modules para instanciar o GKE.

*[Como funcionam os modules?](https://www.terraform.io/docs/language/modules/syntax.html)*


### 2.1 GKE subnet

**Vamos precisar de uma subnet!**
* No ficheiro [./vpc.tf](./vpc.tf) encontram-se as definições da VPC a usar para o K8s
* Também poderiamos configurar a subnet no modulo, mas dificulta a gestão transversal da VPC

```bash
# descomentar a seguinte resource
resource "google_compute_subnetwork" "gke"
resource "google_compute_router" "default" 
resource "google_compute_router_nat" "nat"

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

### 2.2 GKE module

* No ficheiro [./gke.tf](./gke.tf) encontra-se a definição do module
* Por cada module é preciso fazer `terraform init`

```bash
# descomentar o module
module "gke"

# inicializar o modulo
terraform init

# plan & apply (vai demorar 5 minutos aprox)
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# podem consultar os clusters ativos assim
gcloud container clusters list --project tf-gke-lab-01-np-000001 | grep $(terraform output -raw my_identifier)
```

> Enquanto esperamos, vamos falar um pouco sobre os [Terraform Modules](https://www.terraform.io/docs/language/modules/syntax.html)


* Após o cluster estar UP, basta dirigirem-se a esta pagina: <https://console.cloud.google.com/kubernetes/list?project=tf-gke-lab-01-np-000001>
* Seleccionam o vosso cluster e voila!
* Mas e se nós gerarmos a configuração automaticamente...?


### 2.3 Kubeconfig module (module inside a module)

* Nesta secção iremos abordar a utilização de modulos dentro de modules
* Não existe limitações na profundidade das dependências, porém, é preciso ter senso comum para evitar exageros pois o perfeccionismo é um inimigo da funcionalidade.
* A desvantagem é que apenas é possível passar raw-values, sendo sempre necessário obter o data-object caso queiramos aceder a uma resource

**Objectivo: obter a configuração `kubeconfig.yaml` de acesso ao cluster automaticamente**

* No ficheiro [./modules/gke/kubeconfig.tf](./modules/gke/kubeconfig.tf) encontra-se a definição do module
* **Não esquecer**: cada module novo é preciso fazer `terraform init`

```bash
# descomentar o modulo kubeconfig e o respetivo output
module "kubeconfig"
output "gke_kubeconfig"

# init
terraform init

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

**O que está a faltar? Continuamos sem instruções de utilização do `kubeconfig`...😡**

* *O main module também tem que emitir o valor...*

**No ficheiro [./gke.tf](./gke.tf) é necessário adicionar o novo `output` proveniente do module**

```bash
# descomentar o output
output "gke_kubeconfig"

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# deverá existir um output identico a
export KUBECONFIG=kubeconfig.yaml

# se tiverem o `kubectl` instalado, basta fazerem isto para testarem o acesso ao cluster
kubectl get nodes
```

### 2.4. Vamos por workloads a correr?

* Nesta parte iremos usar o [kubectl](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs) provider para instanciar todos os workloads de kubernetes

1. Habilitar o modulo [./k8s.tf](./k8s.tf) descomentando as linhas comentadas

```bash
# init
terraform init

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# ver os pods existentes
kubectl get pods -n hipster-demo

# fazer o port-forward
kubectl port-forward -n hipster-demo service/frontend 8080:80
```

* Após este passo, basta testar a aplicação no port-foward que foi estabelecido no seguinte url: <http://localhost:8080>
* Se estiverem a usar a Google CloudShell podem clicar em `Preview on Port 8080` no canto superior direito.

Portanto, conseguimos validar que os workloads estao a funcionar.
* O próximo passo será expor a partir dos ingresses e respectivos load-balancers do GKE
* Para isso precisamos de um DNS para HTTP/HTTPS
* Caso queiramos usar HTTPS vamos também precisar de um certificado SSL

## 3. DNS

### 3.1 Criar a zona de DNS

* No ficheiro [./dns.tf](./dns.tf) encontra-se a definição do module
* **Não esquecer**: cada module novo é preciso fazer `terraform init`

```bash
# descomentar o modulo e o output
module "dns"
output "fqdn"

# init
terraform init

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# verificar as zonas criadas
gcloud dns managed-zones list | grep $(terraform output -raw my_identifier)
```

### 3.2 Habilitar o `external-dns`

* No ficheiro [./k8s.tf](./k8s.tf) é necessário passar o fqdn devolvido pelo modulo de dns.

```bash
# descomentar a seguinte linha no ficheiro ./k8s.tf
fqdn = module.dns.fqdn
```

* No ficheiro [./modules/k8s/external-dns.tf](./modules/k8s/external-dns.tf) encontra-se a implementação do `external-dns` que permite atualizar os registos DNS automaticamente.

```bash
# descomentar os seguintes
data "google_service_account" "gke_dns
data "kubectl_path_documents" "external_dns"
resource "kubectl_manifest" "external_dns"
```

**Por fim, podemos fazer `init` + `plan` e `apply`**
```bash
# init
terraform init

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

### 3.3 Criar um ponto de entrada (ingress) para o site

* No ficheiro [./modules/k8s/ingress.tf](./modules/k8s/ingress.tf) iremos descomentar a secção 3.2 que fazer com que seja aprovisionado um ingress para o nosso site.

```bash
# descomentar os seguintes
data "kubectl_path_documents" "hipster_ingress"
resource "kubectl_manifest" "hipster_ingress"

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# verificar a existencia de um ingress e esperar por um public IP
kubectl get ingress -n hipster-demo

# monitorizar o external-dns e o cert-manager
kubectl logs -f -n cert-manager -l app=cert-manager
kubectl logs -f -n external-dns -l app=external-dns
kubectl describe ingress -n hipster-demo hipster-ingress
```
## 5. wrap-up & destroy

Destruir os conteúdos!

```bash

# destroy
terraform destroy
```

* **Nota:** se o destroy der erro é porque o terraform não consegue apagar um recurso devido a dependências externas. Isto pode acontecer devido aos recursos que foram criados pela ferramenta `kubectl`.
  * Se for este o caso, então será necessário remover os NEGs à mao para o destroy funcionar.

## Comandos úteis

```bash
# listar as zonas disponiveis para uma dada regiao
gcloud compute zones list | grep europe-west1

# listar network-endpoints
gcloud compute network-endpoint-groups list

# apagar network-endpoints
gcloud compute network-endpoint-groups delete <id>

# delete multiple negs at once
gcloud compute network-endpoint-groups delete $(gcloud compute network-endpoint-groups list --format="value(name)" --project tf-gke-lab-01-np-000001)
```