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

```
npm init -f
npm install
npm start
```