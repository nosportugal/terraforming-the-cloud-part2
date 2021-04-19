# terraforming the cloud - part 2

Temas abordados neste modulo:

* Criação de VPCs
* Criação de modulos de Terraform
* Criação de cluster GKE
* Criação de zonas de DNS


## 0. preparar o ambiente

**autenticar a consola com o GCP**
- Abrir o endereço <https://console.cloud.google.com> e autenticar

```bash
gcloud config set project tf-gke-lab-01-np-000001

## NOTA: para utilizadores do vscode devem executar "gcloud auth login" primeiro
```

**clonar o projecto git que vamos usar**
```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part2 && cd terraforming-the-cloud-part2
```

**obter e instalar a versão do terraform que vamos usar**
```bash
sudo scripts/install-terraform.sh
```

**inicializar o terraform**
```bash
# init & plan & apply
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# obter o prefixo unico & guardar numa variavel (vamos precisar disto mais à frente)
my_identifier=$(terraform output -raw my_identifier)
echo $my_identifier
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
```bash
gcloud compute networks list
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
```

### 3.2 Criar um ponto de entrada (ingress) para o site

* No ficheiro [./gke.tf](./gke.tf) iremos descomentar a secção 3.2 que irá permitir que o site seja acessível via internet como se estivesse em produção.

```bash
# descomentar os seguintes
data "template_file" "hipster_ingress"
resource "local_file" "hipster_ingress"

# plan & apply
terraform plan -out plan.tfplan
terraform apply plan.tfplan

# criar o ingress
kubectl apply -f ./k8s/hipster-demo/.
```

### 3.3 Criar um registo de DNS para o aceder ao site

* Antes de testar o site, temos que criar a entrada no dns para apontar para o ip publico

```bash
# obter o fqdn e o ip publico
kubectl get ingress -n hipster-demo

# no modulo de DNS, no main.tf, descomentar a resource relativa ao A Record
resource "google_dns_record_set" "hipster"

# de seguida, substituir a seguinte secção pelo IP que obtiveram no comando acima
rrdatas = ["INSERIR_AQUI_O_VOSSO_IP_PUBLICO"]
```

após um bocado, será possivel navegar pelo endereço final que podem obter através do seguinte comando:
```bash
echo "http://hipster.$(terraform output -raw fqdn)"
```

## 4. HTTPS e geração de certificados

Fica para outro dia... 😥

## 5. wrap-up & destroy

Destruir os conteúdos!

```bash
# primeiro temos que eliminar os conteudos criados pelo kubectl
kubectl delete -f ./k8s/hipster-demo/.

# destroy
terraform destroy
```

* **Nota:** existe um bug/feature em que o terraform nao é capaz de destruir a VPC porque existe um network-endpoint-group associado (é o public LB do ingress). 
  * Se for este o caso, então será necessário remover os NEGs à mao para o destroy funcionar.

```bash
# listar
gcloud compute network-endpoint-groups list
# apagar
gcloud compute network-endpoint-groups delete <id>
```