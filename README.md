# Mid Course Project
Opsschool Mid Course project. Creates a VPC (on us-east-1 by default) with two availability zones, 
each one with two subnets, one public and one private. The public subnets contain a single NAT, a 
Jenkins master (on one subnet), and a Jenkins node (on the other). Both Jenkins servers are configured
as Consul clients with appropriate health checks.   
The private subnets contain an EKS master and a worker group with two autoscaling groups, one in each subnet, 
and also three Consul servers.   
Once the Jenkins is up and the required credentials are entered, you can configure a pipeline job to get the 
phonebook app from git, dockerfy it, and deploy it to EKS, on two pods with a load-balancer.

# How it's done:
Provisioning is done by terraform, as is the initial python installation on the Jenkins master and node.
All other installation is done via Ansible.  
Once the Jenkins server is up, an SSH node is defined with credentials (you will have to configure it to
select the ubuntu credentials and have a non verifying policy with the node). Docker credentials and a git
SSH key are required, before a Jenkins pipeline that pulls a Jenkinsfile from the following repo can be created
https://github.com/daximillian/phonebook.git

# Requirements:
You will need a machine with the following installed on it to run the enviroment:
- AWS CLI (for aws configure)
- python 3.6
- terraform 0.12.20
- ansible 2.9.2 
- git

You will also need a valid AWS user configured (via aws configure or exporting your access key and secret key) 

# To run:
`git clone https://github.com/daximillian/mid-course-project.git`

## Create terraform statefile S3 bucket: 
`cd terraform/global/s3`  
`terraform init`  
`terraform validate`  
`terraform plan -out S3_state.tfplan`  
`terraform apply "S3_state.tfplan"`  

## Provision:
`cd ../VPC `  
`terraform init`  
`terraform validate`  
`terraform plan -out VPC_project.tfplan`  
`terraform apply "VPC_project.tfplan"`  

## Configure/Install:
`cd ../../../Ansible`  
`chmod 400 ../terraform/global/VPC/VPC-demo-key.pem`  
`ansible all -i ../terraform/global/VPC/hosts.INI -m ping`  
`ansible-playbook jenkins_playbook.yml -i ../terraform/global/VPC/hosts.INI`  

## To run the Jenkins playbook:
- logon to Jenkins master on port 8080 (u/p admin)
- add dockerhub credentials with the id "dockerhub.daximillian"
- add git credentials.
- configure node to work with existing ubuntu credentials and no non-verifying host strategy
- create pipeline from scm, choose git, give it the https://github.com/daximillian/phonebook.git repo and 
your git credentials, and set it up to be triggered by git push. Then set up a webhook in GitHub on your copy of the 
phonebook repo.
- run the build job.
- After successful completion wait a minute or two for the LoadBalancer to finish provisioning. You can ssh to the 
Jenkins node using the VPC-demo-key.pem, then `export KUBECONFIG=<path_to_the_kubeconfig_opsSchool-eks_file>` and run 
`kubectl get svc` to get the address of the loadbalancer. You can also run the same from your workstation if you have kubectl and 
iam-authentication installed. Alternatively you can just logon to the AWS console and see the ELB address there,
or run `aws elb describe-load-balancers` to get the load balancer address.


## To bring everything down:
Terraform may have issues bringing the load balancer down. To avoid these issues you get bring it down yourself with `kubectl delete svc phonebook-lb` or by deleting the load balancer through the AWS console.  
Once the load-balancer is down, cd into the terraform/global/VPC directory and run:  
`terraform destroy`

The s3 statefile bucket is set to not allow it to be accidentaly destroyed. Make sure you know what you're doing before
destroying it.