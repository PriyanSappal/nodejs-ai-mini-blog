variable "mongo_parameter_name" { 
    type = string
 default = "/devops-mini-blog/MONGO_URI" 
 }
variable "openai_parameter_name" { 
    type = string
 default = "/devops-mini-blog/OPENAI_KEY" 
 }
variable "mongo_value" { 
    type = string 
    default = "" 
    }
variable "openai_value" { 
    type = string
     default = "" 
     }