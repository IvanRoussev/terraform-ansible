VPC resource map
![image](https://user-images.githubusercontent.com/50000851/226459643-79998f48-a3d1-4ffc-bd90-94d0ec2211ee.png)


Terraform will create a aws infastructure with the following

This infastructure will then be used by a ansible playbook that can start up a server to run a static web page using nginx. 
The playbook will aslo create a user called ivan with a password and priviledges to only the database created by the terraform script.

    A VPC

        name: acit-4640-vpc

        CIDR: 10.0.0.0/16

    3 subnets:

        Public Subnet

            name: acit-4640-pub-sub

            CIDR: 10.0.1.0/24

            AZ: us-west-2a

        Private Subnet 1

            name: acit-4640-rds-sub1

            CIDR: 10.0.2.0/24

            AZ: us-west-2a

        Private Subnet 2

            name: acit-4640-rds-sub2

            CIDR: 10.0.3.0/24

            AZ: us-west-2b

    An Internet Gateway
        name: acit-4640-igw

    A Route Table

        name: acit-4640-rt

        Add route 0.0.0.0/0 for internet gateway

    2 Security Groups

        EC2 Security group

            name: acit-4640-sg-ec2

            inbound:

                ssh anywhere

                http anywhere

        RDS Security Group

            name: acit-4640-sg-rds

            Allow mysql traffic within the VPC

    An EC2 Instance

        Create an SSH key pair in your Linux environment with ssh-keygen

            Use 'ed25519' as the type for this new key

            key name: acit-4640-key

            Add the key to AWS using terraform

        Use Ubuntu 22.04 for your EC2 Instance

        EC2 instance name: acit-4640-ec2

    An RDS database cluster

        A subnet group that includes
            acit-4640-rds-sub1 and acit-4640-rds-sub2

        Uses RDS security group created above

        name: acit-4640-rds
