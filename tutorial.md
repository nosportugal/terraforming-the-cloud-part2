# terraforming the cloud - part 2

![Terraforming the cloud architecture][tfc-arch]

## Temas abordados neste modulo

* Criação de [modulos de Terraform](https://www.terraform.io/docs/language/modules/syntax.html)
* Criação de [cluster GKE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
* Criação de [zonas de DNS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)
* Utilização de diferentes providers ([kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs))
* [Templates de ficheiros](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)

**Tempo estimado**: Cerca de 2 horas

**Pré requisitos**: Antes de começares, é necessário verificares algumas coisas:

Junta-te à **Cloud Guild** no Teams e segue os tutorias da Wiki do GCP.

Depois pede para te adicionarem ao projeto no GCP.

De seguida vais ter de configurar o GCP. Se já tens o `gcloud` instalado corre este comando:

**NOTA: Se estás a executar tutorial na cloudshell (consola do GCP), não precisas de correr este comando.**

```bash
gcloud auth application-default login
```

Podes econtrar mais info sobre a auth [aqui](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started).

Certifica-te que tens a `google-cloud-shell` devidamente autorizada correndo este comando:

```bash
gcloud config set project tf-gke-lab-01-np-000001
```

De seguida, clica no botão **Start** para começares.

## 0. terraform `init`

Neste projeto temos que preparar um prefixo que identifique unicamente os recursos que vão ser criados, por forma a evitar colisões.

* No ficheiro `./terraform.tfvars` é necessário definir um prefixo, no seguinte formato: `user_prefix = "<valor>"`

Inicializar:

```bash
terraform init
```

Planear:

```bash
terraform plan -out plan.tfplan
```

Aplicar:

```bash
terraform apply plan.tfplan
```

## 1. criar a VPC

* No ficheiro `./vpc.tf` encontram-se as definições da VPC a usar

Descomentar as seguintes resources:

* `resource "google_compute_network" "default"`

*Tip: `CTRL+K+U` é o atalho para descomentar em bloco*

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Validar the a VPC foi criada com a respetiva subnet:

```bash
gcloud compute networks list | grep $(terraform output -raw my_identifier)
```

## 2. Modules & GKE

Neste capitulo iremos abordar a utilização de [terraform modules](https://www.terraform.io/docs/language/modules/syntax.html) para instanciar o GKE.

### 2.1 GKE subnet

Para aprovisionar um GKE é necessário uma subnet. Esta subnet será usada para endereçar as as principais componentes do GKE: `pods`, `services` e `nodes`.

* No ficheiro `./vpc.tf` encontram-se as definições da VPC a usar para o GKE
* Também poderiamos configurar a subnet no modulo, mas dificulta a gestão transversal da VPC

No ficheiro `./vpc.tf`, descomentar as seguintes resources:

* `resource "google_compute_subnetwork" "gke"`
* `resource "google_compute_router" "default"`
* `resource "google_compute_router_nat" "default"`

**Why**: Tanto o `router` como o `nat` são recursos necessários para permitir que o cluster GKE possa aceder à internet para fazer download das imagens dos containers que vamos usar._

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar que a subnet foi corretamente criada:

```bash
gcloud compute networks subnets list --uri | grep "$(terraform output -raw my_identifier)"
```

### 2.2 GKE module

Agora que temos a subnet preparada, iremos entao proceder à primeira aplicação de um [terraform module](https://www.terraform.io/docs/language/modules/syntax.html) para aprovisionar um cluster GKE.

> *[from docs:](https://www.terraform.io/docs/language/modules/syntax.html) A module is a container for multiple resources that are used together.*
>
> *Every Terraform configuration has at least one module, known as its root module, which consists of the resources defined in the .tf files in the main working directory.*
>
> *A module can call other modules, which lets you include the child module's resources into the configuration in a concise way. Modules can also be called multiple times, either within the same configuration or in separate configurations, allowing resource configurations to be packaged and re-used.*

* No ficheiro `./gke.tf` encontra-se a invocação do module
* Por cada module é preciso fazer `terraform init`

No ficheiro `./gke.tf`, descomentar as seguintes resources:

* `module "gke"`
* `output "gke_name"`
* `output "gke_location"`

Primeiro temos que executar `terraform init` para inicializar o modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

<sub>⏰ Notem que a criação de um cluster GKE pode levar até **10 minutos**...</sub>

Podemos verificar que o nosso cluster foi corretamente criado através do comando:

```bash
gcloud container clusters list --project tf-gke-lab-01-np-000001 | grep $(terraform output -raw my_identifier)
```

*Também é possivel verificar o estado do cluster pela GUI [aqui](https://console.cloud.google.com/kubernetes/list?project=tf-gke-lab-01-np-000001).*

### 2.3 Aceder ao cluster

O acesso a um GKE, tal como qualquer outro cluster de Kubernetes, é feito a partir da cli `kubectl`. Para podermos executar comandos `kubectl` precisamos primeiro de garantir que temos uma configuração válida para aceder ao nosso cluster.

Usar o comando `gcloud` para construir um `KUBECONFIG` válido para aceder ao cluster:

```bash
export KUBECONFIG=$(pwd)/kubeconfig.yaml && gcloud container clusters get-credentials $(terraform output -raw gke_name) --zone $(terraform output -raw gke_location) --project tf-gke-lab-01-np-000001
```

Verificar o acesso ao cluster:

```bash
kubectl get nodes
```

### 2.4. Vamos por workloads a correr

Nesta secção abordar a utilização de um provider ([kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs)) para instanciar (via terraform) todos os workloads que vão correr no nosso cluster.

Trata-se de um provider da comunidade que tal como o nome indica, facilita a utilização de terraform para orquestrar ficheiros `yaml`.

> *[from docs:](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs) This provider is the best way of managing Kubernetes resources in Terraform, by allowing you to use the thing Kubernetes loves best - yaml!*

Para habilitar o modulo, temos que ir ao ficheiro `./k8s.tf` e descomentar o seguinte:

* `module "k8s"`
* ❗❗ **não** descomentar a linha `fqdn`; será habilitado mais a frente ❗❗

Os microserviços utilizados nesta demo, encontram-se [neste registry](https://console.cloud.google.com/gcr/images/google-samples/global/microservices-demo). Antes de inicializarem o módulo, verifiquem que as versões destes microserviços (passar pelos ficheiros `./k8s/hipster-demo/*.yaml` ) ainda existem.

Executar `terraform init` para inicializar o modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar que os pods foram corretamente instanciados:

```bash
kubectl get pods -n hipster-demo
```

Também podemos constatar que o cluster-autoscaler teve que aprovisionar mais um node para acautelar o demand 😃🚀

```bash
kubectl get nodes
```

### 2.5. Testar a nossa aplicação

Para testar e validar a nossa aplicação antes de a colocar em "produção", podemos tirar partido da capacidade de fazer `port-forward`.

Para iniciar um `port-forward` no porto `8080`:

```bash
kubectl port-forward -n hipster-demo service/frontend 8080:80
```

* Após este passo, basta testar a aplicação no port-foward que foi estabelecido no seguinte url: <http://localhost:8080>
* Se estiverem a usar a Google CloudShell podem clicar em <walkthrough-web-preview-icon></walkthrough-web-preview-icon> `Preview on Port 8080` no canto superior direito

## 3. DNS & HTTPS

Conseguimos validar que os workloads estao a funcionar.

* O próximo passo será expor a partir dos ingresses e respectivos load-balancers do GKE
* Para isso precisamos de um DNS para HTTP/HTTPS
* Caso queiramos usar HTTPS vamos também precisar de um certificado SSL

### 3.1 Criar a zona de DNS

No ficheiro `./dns.tf` encontra-se a definição do modulo.

Para habilitar o modulo `./dns.tf` precisamos de descomentar as seguintes resources:

* `module "dns"`
* `output "fqdn"`

Executar `terraform init` para inicializar o modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar que a nossa zona de DNS foi corretamente criada através do seguinte comando:

```bash
gcloud dns managed-zones list | grep $(terraform output -raw my_identifier)
```

### 3.2 Habilitar o `external-dns`

O `external-dns` é a *cola* entre o Kubernetes e o DNS.

> *[from docs:](https://github.com/kubernetes-sigs/external-dns) ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers.*

No ficheiro  é necessário passar o fqdn devolvido pelo modulo de dns.

Descomentar a seguinte linha no ficheiro `./k8s.tf`:

* `fqdn = module.dns.fqdn`

No ficheiro `./modules/k8s/external-dns.tf` encontra-se a implementação do `external-dns` que permite atualizar os registos DNS automaticamente.

Descomentar os seguintes recursos no ficheiro `./modules/k8s/external-dns.tf`:

* `data "google_service_account" "gke_dns"`
* `data "kubernetes_namespace" "external_dns"`
* `resource "helm_release" "external_dns"`

Executar `terraform init` para re-inicializar o modulo:

```bash
terraform init
```

**Why**: A razão que temos que voltar a executar o `terraform init` é porque descomentámos o valor de entrada `fqdn` no modulo `k8s.tf`_

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

### 3.3 Criar um ponto de entrada (ingress) para o site

> *[from docs:](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.*

A criação do `ingress` será o culminar das últimas operações que efectuamos (DNS + HTTPS).

* Só será possivel aceder ao nosso site via internet se o expormos a partir de um ingress;
* A criação do ingress irá despoletar a criação de um balanceador com um IP público bem como a geração de um certificado gerido pela Google;
* Após a atribuição do IP, o `external-dns` irá atualizar o DNS com o respetivo IP;
* Uma vez criado o registo no DNS, a GCE irá aprovisionar o certificado automaticamente;
* ⏰ Todo o processo levará cerca de **10 minutos** a acontecer;

No ficheiro `./modules/k8s/ingress.tf` iremos descomentar a secção 3.3 que fazer com que seja aprovisionado um ingress para o nosso site.

Descomentar os seguintes recursos no ficheiro `./modules/k8s/ingress.tf`:

* `data "kubectl_path_documents" "hipster_ingress"`
* `resource "kubectl_manifest" "hipster_ingress"`

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar a criação do `ingress` e a respetiva atribuição de IP a partir dos seguintes comandos:

```bash
kubectl get ingress -n hipster-demo
```

```bash
kubectl describe ingress -n hipster-demo hipster-ingress
```

Também podemos verificar a atuação do `external-dns` assim que o ingress ganhou um IP:

```bash
kubectl logs -f -n external-dns -l app=external-dns
```

> 🚀 Infelizmente, devido ao tempo que a Google demora a gerar os certificados, o site só estará disponível quando o certificado for gerado e a *chain* estiver devidamente validada. Este processo leva cerca de **10 minutos** ⏰😡

Podemos verificar o estado do mesmo usando o seguinte comando:

```bash
kubectl describe managedcertificates -n hipster-demo hipster
```

## 4. wrap-up & destroy

Por fim, podemos destruir tudo de uma só vez.

⏰ Notem que devido à quantidade de recursos envolvidos, a operação de destroy pode demorar entre **10 a 20 minutos**.

```bash
terraform destroy
```

🔚🏁 Chegámos ao fim 🏁🔚

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

<!-- markdownlint-disable-file MD013 -->
<!-- markdownlint-disable-file MD033 -->

 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

[tfc-arch]: https://github.com/nosportugal/terraforming-the-cloud-part2/raw/main/images/terraforming-the-cloud.png "Terraforming the cloud architecture"
