terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "xxx-tfstate-bucket" # fake
    region     = "us-east-1"
    key        = "stage.tfstate"
    access_key = "h7kEG5dt7zt4z4E0HJ"                       # fake
    secret_key = "sF4hzt0WdQuDWCdA92AlX--3mErDYbiUrfDDERiA" # fake

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
