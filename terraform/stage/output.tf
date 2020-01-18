output "webservers_public_address" {
    value = module.webserver_cluster.webservers_public_address
}

output "dbservers_private_addresses" {
    value = module.webserver_cluster.dbservers_private_addresses
}

output "elb_dns" {
    value = module.webserver_cluster.elb_dns
}
