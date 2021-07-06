# terraforming the cloud - part 2

![Terraforming the cloud architecture][tfc-arch]

Temas abordados neste modulo:

* Criação de VPCs
* Criação de modulos de Terraform
* Criação de cluster GKE
* Criação de zonas de DNS

## setup do ambiente

Antes de iniciar a workshop propriamente dita, é necessário efetuar uma preparação do ambiente da cloudshell (ou VSCode) para que possam executar os comandos num ambiente já previamente preparado.

Abaixo seguem dois guias para configuração em:

1. Google Cloud Shell
2. Visual Studio Code

### configurar a cloud shell

Abrir o endereço <https://console.cloud.google.com> e autenticar.

De seguida, ativar a cloud shell:

![tfc-cloudshell-activate]

...abrir em nova janela:

![tfc-cloushell-open-new]

...abrir editor:

![tfc-cloushell-open-editor]

...fechar a janela do terminal no fundo:

![tfc-cloushell-close-terminal]

...abrir novo terminal (embebido no editor):

![tfc-cloushell-new-terminal]

...abrir o editor na pasta do projeto:

![tfc-cloushell-open-folder]

E agora que têm o editor pronto, podemos autenticar a consola com o GCP:

```bash
gcloud config set project tf-gke-lab-01-np-000001
```

### configurar o vscode

> apenas válido para vscode em WSL (windows-subsystem-linux) - instalações em powershell não são suportadas

Caso decidam usar o `vscode`, é necessário garantirem que têm os seguintes binários instalados.
As instruções que seguem vão instalar as tools necessárias:

1. terraform
2. kubectl
3. gcloud

```bash
# instalar as tools necessárias (podem skipar se já têm instaladas)
sudo ./scripts/install-terraform.sh        # terraform
sudo ./scripts/install-kubectl.sh          # kubectl
curl https://sdk.cloud.google.com | bash   # gcloud

# reinicializar a shell
exec -l $SHELL

# inicializar o cliente gcloud
gcloud init
gcloud auth application-default login
```

## 0. terraform init

clonar o projecto git que vamos usar

```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part2 && cd terraforming-the-cloud-part2
```

preparar um prefixo pessoal (pode ser um nome simples sem espaços nem caracteres estranhos

* No ficheiro [./terraform.tfvars](./terraform.tfvars) é necessário definir um prefixo

```bash
# obrigatório preencher (tem que ser entre aspas)
user_prefix = "<valor>"
```

inicializar o terraform

```bash
# init & plan & apply
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## 1. criar a VPC

* No ficheiro [./vpc.tf](./vpc.tf) encontram-se as definições da VPC a usar

Descomentar as seguintes resources

```bash
# vpc
resource "google_compute_network" "default"
```

Plan & Apply

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
output "gke_name"
output "gke_location"

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

### 2.3 Aceder ao cluster

Verificar que o cluster está a correr com sucesso:

```bash
# usar o gcloud para obter as credenciais
export KUBECONFIG=$(pwd)/kubeconfig.yaml && gcloud container clusters get-credentials $(terraform output -raw gke_name) --zone $(terraform output -raw gke_location) --project tf-gke-lab-01-np-000001

# se tiverem o `kubectl` instalado, basta fazerem isto para testarem o acesso ao cluster
kubectl get nodes
```

### 2.4. Vamos por workloads a correr

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
data "google_service_account" "gke_dns"
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

* No ficheiro [./modules/k8s/ingress.tf](./modules/k8s/ingress.tf) iremos descomentar a secção 3.3 que fazer com que seja aprovisionado um ingress para o nosso site.

```bash
# descomentar os seguintes
data "kubectl_path_documents" "hipster_ingress"
resource "kubectl_manifest" "hipster_ingress"

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# verificar a existencia de um ingress e esperar por um public IP
kubectl get ingress -n hipster-demo

# monitorizar o external-dns, ingress e a geração do certificado
kubectl logs -f -n external-dns -l app=external-dns
kubectl describe ingress -n hipster-demo hipster-ingress
kubectl describe managedcertificates -n hipster-demo hipster
```

## 4. wrap-up & destroy

Destruir os conteúdos!

```bash
# destroy
terraform destroy
```

## Trabalhar com o projeto full (sem código comentado)

Se por ventura quiserem experimentar o projeto sem terem que andar a descomentar, podem obter uma versão descomentada do projeto a partir da `workshop-full` branch:

<https://github.com/nosportugal/terraforming-the-cloud-part2/tree/workshop-full>

Para poderem clonar o código na branch, deverão fazer o seguinte:

```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part2.git
git checkout workshop-full
```

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

# verificar as versoes dos release channels
gcloud container get-server-config --format "yaml(channels)" --zone europe-west1-b
```
<!-- markdownlint-disable-file MD013 -->

 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

[tfc-arch]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/terraforming-the-cloud.png "Terraforming the cloud architecture"

[tfc-cloudshell-activate]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/cloudshell-activate.png "Cloudshell activate screenshot"

[tfc-cloushell-open-new]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/cloudshell-open-new.png "Cloudshell open new window screenshot"

[tfc-cloushell-open-editor]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/cloudshell-open-editor.png "Cloudshell open editor screenshot"

[tfc-cloushell-close-terminal]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/cloudshell-close-terminal.png "Cloudshell close terminal window screenshot"

[tfc-cloushell-new-terminal]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/cloudshell-new-terminal.png "Cloudshell new terminal window screenshot"

[tfc-cloushell-open-folder]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/cloudshell-open-folder.png "Cloudshell open folder screenshot"
