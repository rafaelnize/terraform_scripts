# Configure the CloudStack Provider
provider "cloudstack" {
    api_url = "${var.cstk_api_url}"
    api_key = "${var.cstk_api_key}"
    secret_key = "${var.cstk_secret_key}"
}

# Create a web server
resource "cloudstack_instance" "web" {
    name = "tf_srv_web01"
    service_offering = "c1-small"
    network = "MLZ-ACS-VLAN-1747-DEVMLZ-ACS-VLAN-1747-DEV"
    template = "TPL-Ubuntu-14.04-x64-5GB-v1.0"
    zone = "1"
}
