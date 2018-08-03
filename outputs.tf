#
# in Terraform 0.12 (forthcoming, as of this writing) there will be more
# complex data types available as well as more powerful iteration support and
# so hopefully the use of data structures here will be reduced and simplified.

output "lbr_nodes" {
  description = "Load Balancer/Router node information"
  value = {
    "users" = [ "${openstack_compute_instance_v2.lbr_node.*.metadata.user}" ]
    "names" = [ "${openstack_compute_instance_v2.lbr_node.*.name}" ]
    "ips"   = [ "${openstack_networking_floatingip_v2.lbr_fip.*.address}" ]
  }
}

output "pp_nodes" {
  description = "Persistent Private node information"
  depends_on = [ "openstack_compute_instance_v2.pp_node" ]
  value = {
    "users"     = [ "${openstack_compute_instance_v2.pp_node.*.metadata.user}" ]
    "jumphosts" = [ "${openstack_compute_instance_v2.pp_node.*.metadata.jumphost}" ]
    "names"     = [ "${openstack_compute_instance_v2.pp_node.*.name}" ]
    "ips"       = [ "${openstack_compute_instance_v2.pp_node.*.network.0.fixed_ip_v4}" ]
  }
}

locals {
  lbr_iplookup = "${zipmap(openstack_compute_instance_v2.lbr_node.*.name, openstack_networking_floatingip_v2.lbr_fip.*.address)}"
  lbr_userlookup = "${zipmap(openstack_compute_instance_v2.lbr_node.*.name, openstack_compute_instance_v2.lbr_node.*.metadata.user)}"
  pp_iplookup = "${zipmap(openstack_compute_instance_v2.pp_node.*.name, openstack_compute_instance_v2.pp_node.*.network.0.fixed_ip_v4)}"
  pp_userlookup = "${zipmap(openstack_compute_instance_v2.pp_node.*.name, openstack_compute_instance_v2.pp_node.*.metadata.user)}"
}

output "iplookup" {
  value = "${merge(local.lbr_iplookup, local.pp_iplookup)}"
}

output "userlookup" {
  value = "${merge(local.lbr_userlookup, local.pp_userlookup)}"
}
