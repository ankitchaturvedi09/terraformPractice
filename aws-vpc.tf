
provider "aws" {
	region = "${var.aws_region}"
	shared_credentials_file = "${var.aws_creds_file}"
	}

resource "aws_vpc" "devVpc" {
	cidr_block = "${var.aws_dev_vpc_cidr_block}"

	tags {
		Name = "${var.aws_dev_vpc_name}"
	}
}

resource "aws_internet_gateway" "devVpcGateway" {
	vpc_id = "${aws_vpc.devVpc.id}"
}

resource "aws_security_group" "devSecurityGroup" {
	name = "devSecurityGroup"
	description = "Security Group for dev VPC"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	vpc_id = "${aws_vpc.devVpc.id}"

}

resource "aws_subnet" "subnetPrivate" {
	vpc_id = "${aws_vpc.devVpc.id}"
	cidr_block = "${var.aws_private_cidr_block}"

	tags {
		Name = "${var.aws_subnet_private_name}"
	}
} 

resource "aws_subnet" "subnetProtected" {
        vpc_id = "${aws_vpc.devVpc.id}"
        cidr_block = "${var.aws_protected_cidr_block}"

        tags {
                Name = "${var.aws_subnet_protected_name}"
        }
}

resource "aws_subnet" "subnetPublic" {
        vpc_id = "${aws_vpc.devVpc.id}"
        cidr_block = "${var.aws_public_cidr_block}"

        tags {
                Name = "${var.aws_subnet_public_name}"
        }
}

resource "aws_instance" "privateVM" {
	ami = "${var.aws_ami}"
	instance_type = "${var.aws_instance_type}"
	key_name = "${var.aws_key_name}"
	subnet_id = "${aws_subnet.subnetPrivate.id}"
	associate_public_ip_address = true
	security_groups = ["${aws_security_group.devSecurityGroup.id}"]
	tags {
		Name = "${var.aws_private_instance_name}"
		Description = "VM 1"
	}
}

resource "aws_instance" "protectedVM" {
        ami = "${var.aws_ami}"
        instance_type = "${var.aws_instance_type}"
        key_name = "${var.aws_key_name}"
        subnet_id = "${aws_subnet.subnetProtected.id}"
        associate_public_ip_address = true
        security_groups = ["${aws_security_group.devSecurityGroup.id}"]
        tags {
                Name = "${var.aws_protected_instance_name}"
                Description = "VM 2"
        }
}

resource "aws_instance" "publicVM" {
        ami = "${var.aws_ami}"
        instance_type = "${var.aws_instance_type}"
        key_name = "${var.aws_key_name}"
        subnet_id = "${aws_subnet.subnetPublic.id}"
        associate_public_ip_address = true
        security_groups = ["${aws_security_group.devSecurityGroup.id}"]
        tags {
                Name = "${var.aws_public_instance_name}"
                Description = "VM 3"
        }
}