# terraform-gcp-gke-lab-01

Temas abordados neste modulo:

* Criação de VPCs
* Criação de modulos de Terraform
* Criação de cluster GKE
* Criação de zonas de DNS


## 0. setup inicial

```bash
# atualizar o terraform para a ultima versao
tfversion=0.14.7 && \ 
  tfzip=terraform_${tfversion}_linux_amd64.zip && \
  wget https://releases.hashicorp.com/terraform/$tfversion/$tfzip && \
  unzip $tfzip && \
  sudo mv -f terraform /usr/local/bin/terraform && \
  rm $tfzip

# validar a versão do terraform
terraform --version

# efectuar o login no GCP
gcloud auth login && gcloud config set project tf-gke-lab-01-np-000001

# init & plan & apply
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# obter o prefixo unico & guardar numa variavel
my_identifier=$(terraform output my_identifier)
echo $my_identifier
```

## 1. criar a VPC

* No ficheiro [./vpc.tf](./vpc.tf) encontram-se as definições da VPC a usar

**Descomentar as seguintes resources**

```bash
# vpc
resource "google_compute_network" "default"
# subnet
resource "google_compute_subnetwork" "default"
```

**Plan & Apply**
```bash
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```
*Validar the a VPC foi criada com a respetiva subnet...*

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
```

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
# module "kubeconfig"
# output "gke_kubeconfig"

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
# output "gke_kubeconfig"

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# deverá existir um output identico a
export KUBECONFIG=kubeconfig.yaml

# se tiverem o `kubectl` instalado, basta fazerem isto para testarem o acesso ao cluster
kubectl get nodes
```

### 2.4. Vamos por workloads a correr?

* Nesta parte iremos usar o kubectl para instanciar uma aplicação de demo
* O objectivo será fazer um port-forward para testar app

```bash
# testar que chegamos ao cluster
kubectl get nodes
kubectl version

# vamos aplicar o hipster-demo
kubectl apply -f ./k8s/hipster-demo

# vamos aguardar que a aplicação inicie (apenas termina quando o pod load-generator tiver corrido com sucesso)
kubectl get pods -n hipster-demo -w

# obter os serviços e obter o porto do frontend
kubectl get services -n hipster-demo | grep frontend

# fazer o port-forward
kubectl port-forward -n hipster-demo service/frontend 8001:80
```

**Após este passo, basta testar a aplicação no port-foward que foi estabelecido no seguinte url: <http://localhost:8001>**

Portanto, conseguimos validar que os workloads estao a funcionar.
* O próximo passo será expor a partir dos ingresses e respectivos load-balancers do GKE
* Para isso precisamos de um DNS para HTTP/HTTPS
* Caso queiramos usar HTTPS vamos também precisar de um certificado

## 3. DNS for HTTPS and auto-certificate generation

**Next time?**

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
```

### 3.2 Criar e testar o ingress

* No ficheiro [./gke.tf](./gke.tf) iremos descomentar a secção 3.2

```bash
# descomentar os seguintes
data "template_file" "hipster_ingress"
resource "local_file" "hipster_ingress"

# criar o ingress
kubectl apply -f ./k8s/hipster-demo/.

# obter o fqdn e o ip publico
kubectl get ingress -n hipster-demo
```

* após um bocado, será possivel navegar pelo endereço final <https://hipster.fqdn>

## 4. wrap-up & destroy

Destruir os conteúdos!

```bash
# destroy
terraform destroy
```