# Jenkins

This guide uses the docker container for Jenkins' [Blue Ocean](https://jenkins.io/projects/blueocean/), specifically designed as a simplified GUI for the Jenkins Pipeline.

## Setup

[Jenkins](https://jenkins.io/) can be run as a remote server, or in this case, locally using [docker](https://www.docker.com/).

### Start the container

The following command runs the Jenkins server in the background with the name `docker-jenkins` for easy access. On the first run, a docker [volume](https://docs.docker.com/storage/volumes/) called `jenkins-data` is created and mounted as the Jenkins home directory.

##### Linux

```bash
docker run \
  -d \
  --name docker-jenkins \
  -u root \
  -p 8080:8080 \
  -v jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean
```


##### Windows

```
docker run ^
  -d ^
  --name docker-jenkins ^
  -u root ^
  -p 8080:8080 ^
  -v jenkins-data:/var/jenkins_home ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  jenkinsci/blueocean
```

After startup, the server's web portal can be accessed via [http://localhost:8080](http://localhost:8080).

Note: Since Jenkins will be running in docker, and docker will also be utilized within the Jenkins pipeline to run [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/), it is also important to mount `docker.sock` from the host. That way, the docker controller in Jenkins uses the host's docker daemon to run its containers.

### Get admin password

<img src="static/unlock.jpg" width="400">

The admin password for Jenkins is created when the container is started with a new volume. If running Jenkins in the foreground, you'll get the following message toward the end of the output:

```bash
Please use the following password to proceed to installation:

(redacted)

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

If running Jenkins in the background, you can access the admin password with this command:

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