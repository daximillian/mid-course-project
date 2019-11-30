output "webservers_public_address" {
    value = aws_instance.webservers.*.public_ip
}

output "dbservers_private_addresses" {
    value = aws_instance.dbservers.*.private_ip
}

output "elb_dns" {
    value = aws_elb.terra-elb.dns_name
}
