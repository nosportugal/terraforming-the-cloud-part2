# terraforming the cloud - part 2

![Terraforming the cloud architecture][tfc-arch]

Temas abordados neste modulo:

* Criação de [modulos de Terraform](https://www.terraform.io/docs/language/modules/syntax.html)
* Criação de [cluster GKE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
* Criação de [zonas de DNS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)
* Utilização de diferentes providers ([kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs))
* [Templates de ficheiros](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)

## iniciar o tutorial (setup automatico)

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/nosportugal/terraforming-the-cloud-part2&cloudshell_tutorial=tutorial.md)

---

## setup do ambiente (manual)

Esta secção explica como preparar o IDE para poderem executar os comandos do tutorial.

Abaixo seguem dois guias para configuração em:

1. Google Cloud Shell
2. Visual Studio Code

### configurar a cloud shell

Abrir o endereço <https://console.cloud.google.com> e autenticar.

De seguida, ativar a cloud shell:

![tfc-cloudshell-activate]

Abrir em nova janela:

![tfc-cloushell-open-new]

Abrir editor:

![tfc-cloushell-open-editor]

Fechar a janela do terminal no fundo:

![tfc-cloushell-close-terminal]

Abrir novo terminal (embebido no editor):

![tfc-cloushell-new-terminal]

Clonar o projeto:

```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part2 && cd terraforming-the-cloud-part2
```

Abrir o editor na pasta do projeto:

![tfc-cloushell-open-folder]

E agora que têm o editor pronto, podemos autenticar a consola com o GCP:

```bash
gcloud config set project tf-gke-lab-01-np-000001
```

## configurar o vscode

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

# definir o projeto por defeito (opcional)
gcloud config set project tf-gke-lab-01-np-000001
```

Por fim, podemos clonar o projeto:

```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part2 && cd terraforming-the-cloud-part2
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
# obter a lista de machine-types
gcloud compute machine-types list --zones=europe-west1-b --sort-by CPUS

# listar a lista de regioes disponiveis
gcloud compute regions list

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
