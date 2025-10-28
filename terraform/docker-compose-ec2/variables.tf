variable "region" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "PORT" {
  default = "3000"
}

variable "devops_public_key" {
  description = "Public Key for EC2 access"
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API key"
  sensitive   = true
}

variable "mongo_uri" {
  description = "MongoDB connection string"
  sensitive   = true
}
