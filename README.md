# lambda-provisioner

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?logo=amazonaws&logoColor=white)

A single `terraform apply` builds a VPC and an EC2 instance from the official **Terraform Registry modules**. It generates an SSH key and an Ansible inventory, then runs an Ansible playbook that installs and starts **nginx**.

## Contents

- [What gets created](#what-gets-created)
- [Flow](#flow)
- [Project layout](#project-layout)
- [Usage](#usage)
- [Variables](#variables)
- [Outputs](#outputs)
- [Cost notes](#cost-notes)

## What gets created

| Component       | Implementation                                                                 |
|-----------------|--------------------------------------------------------------------------------|
| VPC             | [`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws): public + private subnets, optional NAT and VPN gateways |
| Security group  | [`terraform-aws-modules/security-group/aws`](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws): SSH only from **your current public IP** (detected via `data "http"` → ifconfig.io); ports from `var.ports` open only to the private subnets |
| EC2 instance    | [`terraform-aws-modules/ec2-instance/aws`](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws) with a public IP |
| SSH key         | `tls_private_key` (RSA 4096) → `.ssh/id_rsa_instance.pem` + `aws_key_pair`     |
| Configuration   | `local_file` renders `inventory.ini`; a `null_resource` runs `ansible-playbook` |

Every resource gets common tags from `locals.tf`: `Managed_by`, `env`, `Region`, `Owner`.

## Flow

```
terraform apply
   │
   ├─ data.http.myip ──────────────► your public IP for the SSH rule
   ├─ module.vpc ──► module.vote_service_sg ──► module.ec2_instance
   ├─ tls_private_key ──► .ssh/id_rsa_instance.pem + aws_key_pair
   ├─ local_file ──► inventory.ini (from templates/inventory.tpl)
   └─ null_resource.init ──► ansible-playbook scripts/playbook.yml ──► nginx
```

The provisioner re-runs whenever the instance's public IP changes (`triggers.instance_ip`).

## Project layout

```
versions.tf                AWS provider (~> 6.0), data sources: my IP, AZs
vars.tf                    input variables
terraform.example.tfvars   example values
locals.tf                  common tags
main.tf                    VPC, security group, EC2, inventory, Ansible run
ssh.tf                     key generation
outputs.tf                 public_ip, public_dns
templates/inventory.tpl    Ansible inventory template
scripts/playbook.yml       install and start nginx
```

## Usage

**Requirements:** Terraform ≥ 1.5, Ansible on the machine that runs Terraform, and AWS credentials in the environment.

```bash
cp terraform.example.tfvars terraform.tfvars
```

Add the two required variables that are not in the example file:

```hcl
sec_group_name = "web-sg"
subnet_main    = "10.0.1.0/24"
```

Then:

```bash
terraform init
terraform apply
```

Connect to the instance:

```bash
ssh -i .ssh/id_rsa_instance.pem ec2-user@$(terraform output -raw public_ip)
```

Clean up:

```bash
terraform destroy
```

`terraform.tfvars`, the generated key, `inventory.ini` and state files are all git-ignored.

## Variables

| Name                  | Type         | Default          | Description                                        |
|-----------------------|--------------|------------------|----------------------------------------------------|
| `region`              | string       | `us-east-1`      | AWS region                                         |
| `env`                 | string       | `dev`            | environment name, used in tags                     |
| `vpc_name`            | string       | —                | VPC name                                           |
| `vpc_cidr`            | string       | —                | VPC CIDR block                                     |
| `private_subnets`     | list(string) | —                | private subnet CIDRs                               |
| `public_subnets`      | list(string) | —                | public subnet CIDRs                                |
| `enable_nat_gateway`  | bool         | —                | create a NAT gateway                               |
| `enable_vpn_gateway`  | bool         | —                | create a VPN gateway                               |
| `sec_group_name`      | string       | —                | security group name                                |
| `ports`               | set(string)  | `["80", "443"]`  | TCP ports opened to the private subnets            |
| `instance_type`       | string       | `t2.micro`       | EC2 instance type                                  |
| `detailed_monitoring` | bool         | `false`          | enable detailed CloudWatch monitoring              |
| `subnet_main`         | string       | —                | declared but not used yet                          |

## Outputs

| Name         | Description                     |
|--------------|---------------------------------|
| `public_ip`  | public IP of the instance       |
| `public_dns` | public DNS name of the instance |

## Cost notes

NAT and VPN gateways are billed by the hour even when idle. The example tfvars enables both. For quick experiments, set:

```hcl
enable_nat_gateway = false
enable_vpn_gateway = false
```

## Workflow

Development happens on the `dev` branch and is merged into `main` through pull requests.
