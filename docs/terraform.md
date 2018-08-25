<img src="static/Terraform_PrimaryLogo_FullColor.png" width="400">

# Deploy with Terraform



  
## Removal

Get latest `terraform.tfstate` file

```git pull```

Destroy the deployment

```
terraform init config
terraform destroy -auto-approve config
```

(Don't forget to deregister the AMI)
