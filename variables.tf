variable "keypair" {
  default = ""
}

# list of names for LBR nodes.  This list will determine how many such nodes 
# get created.
variable "lbr_names" {
  default = []
}

# list of names for PP nodes.  This will determine how many such nodes get 
# created.
variable "pp_names" {
  default = []
}


# including the defaults to show structure and usage, but does not actually
# work, you need to define your defaults in your own variable.  This still
# needs to be here so the module accepts it
variable "node_spec" {
  default = {
    # name of the flavor you want to use
    flavor = "p2-1.5gb"

    # name of image you want to use
    image = "Ubuntu-18.04-Bionic-minimal-x64-2018-07"

    # name of network to attach to node.  At this stage, only one can be added
    # but it should be possible in the near future (Terraform 0.12) to support
    # dynamic collections within resource definitions
    network = "c3tp-collab_network"

    # pool from which to draw floating IPs
    # (only used for LBR nodes)
    floating_ip_pool = "net04_ext"

    # jump host for node (only used for PP nodes, and only used for generated
    # files)
    jumphost = "lbr01"

    # size of root disk, for use with a persistent flavour
    rootdisk = 10
  }
}
