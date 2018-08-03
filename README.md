# terraform-openstack-cc-basic

Terraform OpenStack module for simple deployments.

Work in progress.

## Example usage

### `terraform.tfvars`

```
keypair = "aluminum"

lbr_names = [
  "lbr01",
  "lbr02"
]

lbr_spec = {
  flavor = "p2-1.5gb"
  image = "Ubuntu-18.04-Bionic-minimal-x64-2018-07"
  network = "c3tp-collab_network"
  floating_ip_pool = "net04_ext"
}

db_names = [ "db01" ]

db_spec = {
  flavor = "p4-7.5gb"
  image = "Ubuntu-18.04-Bionic-minimal-x64-2018-07"
  network = "c3tp-collab_network"
  jumphost = "lbr01"
}
```

### `my-tenant.tf`

```
variable "keypair" {}

variable "lbr_names" { default = [] }
variable "lbr_spec" {
  default = {
    rootdisk = 10
  }
}

variable "db_names" { default = [] }
variable "db_spec" {
  default = {
    rootdisk = 20
  }
}

# module name differentiates between multiple instances of a module
module "lbrs" {
  source = "github.com/computecanada/terraform-openstack-cc-basic"

  keypair = "${var.keypair}"

  # load balancer/router nodes
  lbr_names = "${var.lbr_names}"
  node_spec = "${var.lbr_spec}"
}

module "dbs" {
  source = "github.com/computecanada/terraform-openstack-cc-basic"

  keypair = "${var.keypair}"

  # first batch of persistent private nodes is database server
  pp_names = "${var.db_names}"
  node_spec = "${var.db_spec}"
}

output "nodes" {
  description = "Description of created resources"
  value = {
    "lbrs" = "${module.lbrs.lbr_nodes}"
    "dbs"  = "${module.dbs.pp_nodes}"
  }
}
output "iplookup" {
  description = "Lookup of created resources to IPs"
  value = "${merge(module.lbrs.iplookup, module.dbs.iplookup)}"
}
output "userlookup" {
  description = "Lookup of node name to user name"
  value = "${merge(module.lbrs.userlookup, module.dbs.userlookup)}"
}

```

It is possible to exploit the module's output as in the above client outputs `nodes`, `iplookup` and `userlookup` using such as `terraform output -json` as input to scripts which can then create configuration files for SSH, Ansible and other tools.
