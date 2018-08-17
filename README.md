# node-app

### Start Jenkins

Linux:

```bash
docker run -it \
  --name docker-jenkins \
  -p 8080:8080 \
  -u root \
  -v ./jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean
```

Windows:

```
docker run -it ^
  --name docker-jenkins ^
  -p 8080:8080 ^
  -u root ^
  -v ./jenkins_home:/var/jenkins_home ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  jenkinsci/blueocean
```

### Get admin password

Linux

```bash
docker exec -it docker-jenkins \
  /bin/bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
```

Windows

```bash
docker exec -it docker-jenkins ^
  /bin/bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
```

### Create credential entries

AWS

**images

Github

**images

### Create pipeline from Github repo

**images

### Remove project

Get latest `terraform.tfstate` file

```git pull```

Destroy the deployment

```
terraform init config
terraform destroy -auto-approve config
```

(Don't forget to deregister the AMI)
