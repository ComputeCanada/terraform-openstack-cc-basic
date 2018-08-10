# get local variables
locals {
  lbr_count = "${length(var.lbr_names)}"
  pp_count  = "${length(var.pp_names)}"
}

# used to determine the UUID of the desired flavor
data "openstack_compute_flavor_v2" "node_flavor" {
  name = "${var.node_spec["flavor"]}"
}

# used to determine the UUID of the desired image
data "openstack_images_image_v2" "node_image" {
  name = "${var.node_spec["image"]}"
}

#
# Load Balancer/Router nodes
#
# These are nodes with a persistent root disk and a floating IP.
#

# floating IP resource for node
resource "openstack_networking_floatingip_v2" "lbr_fip" {
  count = "${local.lbr_count}"
  pool = "${var.node_spec["floating_ip_pool"]}"
}

# node definition
resource "openstack_compute_instance_v2" "lbr_node" {
  count           = "${local.lbr_count}"
  name            = "${element(var.lbr_names, count.index)}"
  flavor_id       = "${data.openstack_compute_flavor_v2.node_flavor.id}"
  key_pair        = "${var.keypair}"
  security_groups = ["default"]
  user_data       = "${lookup(var.node_spec, "user_data", "")}"

  block_device {
    uuid                  = "${data.openstack_images_image_v2.node_image.id}"
    source_type           = "image"
    volume_size           = "${var.node_spec["rootdisk"]}"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = "${lookup(var.node_spec, "delete_on_terminate", "false")}"
  }

  metadata {
    user = "${var.node_spec["user"]}"
  }

  network {
    name = "${var.node_spec["network"]}"
  }
}

# association between floating IP and node resources
resource "openstack_compute_floatingip_associate_v2" "lbr_fip" {
  count = "${local.lbr_count}"
  instance_id = "${element(openstack_compute_instance_v2.lbr_node.*.id, count.index)}"
  floating_ip = "${element(openstack_networking_floatingip_v2.lbr_fip.*.address, count.index)}"
}

#
# Persistent Private nodes
#
# These are nodes with a persistent root disk and no floating IP.
#

# node definition
resource "openstack_compute_instance_v2" "pp_node" {
  count           = "${local.pp_count}"
  name            = "${element(var.pp_names, count.index)}"
  flavor_id       = "${data.openstack_compute_flavor_v2.node_flavor.id}"
  key_pair        = "${var.keypair}"
  security_groups = ["default"]
  user_data       = "${lookup(var.node_spec, "user_data", "")}"

  block_device {
    uuid                  = "${data.openstack_images_image_v2.node_image.id}"
    source_type           = "image"
    volume_size           = "${var.node_spec["rootdisk"]}"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = "${lookup(var.node_spec, "delete_on_terminate", "false")}"
  }

  metadata {
    user     = "${var.node_spec["user"]}"
    jumphost = "${var.node_spec["jumphost"]}"
  }

  network {
    name = "${var.node_spec["network"]}"
  }
}
