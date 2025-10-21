resource "aws_ssm_parameter" "mongo_uri" {
name = var.mongo_parameter_name
type = "SecureString"
value = var.mongo_value
overwrite = true
}


resource "aws_ssm_parameter" "openai_key" {
name = var.openai_parameter_name
type = "SecureString"
value = var.openai_value
overwrite = true
}


output "parameter_names" {
value = {
mongo = aws_ssm_parameter.mongo_uri.name
openai = aws_ssm_parameter.openai_key.name
}
}