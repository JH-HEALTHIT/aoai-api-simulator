# Building and Deploying the Azure OpenAI Simulator

This fork of the [Azure OpenAI Simulator](https://github.com/microsoft/aoai-api-simulator) includes the files and fixes necessary to deploy the application to the PMAP Dev AKS cluster.

## Building the Docker Container

The [build pipeline](https://dev.azure.com/JH-HealthIT/HGR-VTE/_build?definitionId=124) will build and push a Docker image to the JH PMAP ACR. To build, push a tag to the appropriate commit in the format `build/v<SemVer>-<Unique>`, where `<SemVer>` is the semantic version of the image to deploy (e.g. `1.11.0` or `2.0.0`) and `<Unique>` is a unique string (such as the date, `20250717`), which looks like `build/v1.11.0-20250717`. This will kick off a build in Azure DevOps.

## Deploying the Simulator

The [release pipeline](https://dev.azure.com/JH-HealthIT/HGR-VTE/_build?definitionId=125) will deploy the simulator to the PMAP Dev AKS cluster. It pulls values from the AzDO library [hgr-aoai-simulator-dev](https://dev.azure.com/JH-HealthIT/HGR-VTE/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=22&path=hgr-aoai-simulator-dev) and uses them to deploy. To deploy, push a tag to the appropriate commit in the format `release/v<SemVer>-<Unique>`, where `<SemVer>` is the semantic version of the image to deploy (e.g. `1.11.0` or `2.0.0`) and `<Unique>` is a unique string (such as the date, `20250717`), which looks like `release/v1.11.0-20250717`. The image version must already exist in the JH PMAP ACR.

## Deploying the Infrastructure

If the infrastructure needs to be deployed or updated, the Terraform project can be found under the [/infra/terraform](./infra/terraform/) folder and can be deployed with a `terraform apply` command. No workspaces or variable files are necessary.
