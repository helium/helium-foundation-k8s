# Devops Flow

This repo is managed by GitOps via [ArgoCd](https://argo-cd.readthedocs.io/en/stable/)

What this means is that any code that reaches `master` in this repo is automatically deployed
to the various k8s clusters. 

The Helium k8s infrastructure is provisioned by terraform from helium/helium-foundation-terraform


## Structure

The repo is structured is follows:

```
manifests/
  oracle-cluster
    prod
    sdlc
  web-cluster
    prod
    sdlc
      <namspace>
        <file.yaml>
```

You should generally follow the path of `<cluster>/<env>/<namespace>/<name>


# Case Study: Ecc Verifier Service

This is a stream of consciousness of deploying the ECC Verifier service, for th sake of anyone that wants to figure out devops flow. 

## Building The Service

You can see a PR here https://github.com/helium/helium-program-library/pull/114

Notably, the service has a Dockerfile. This allows us to run the service in kubernetes.

### Creating the ECR Repo

To push a container, you first need to create a repository in ECR for it. Go to your dewi gmail, then click apps, then click AWS SSO. We use the SDLC ECR for BOTH prod and sdlc. The reason is that all flows should be tested in sdlc
first. This allows us to just use the tested sdlc containers on prod, without a separate push. 

Once authenticated, log in to one of the sdlc  aws accounts.

Navigate to ECR. Click "Create Repository". 

Come up with a reasonable name, and make it public. For this, I created `public.ecr.aws/v0j6k5v6/ecc-verifier`

### Pushing the Docker Container

To push the docker container, first you need to login to ECR via the CLI. To do that, you need to setup your aws cli.

Download the AWS Cli. Then follow this guide: https://www.notion.so/AWS-Access-7078d6c1ed92410eb0c391b423359931

```
aws sso login --profile web-sdlc
```

I tend to set the profile names as something memorable. `web-prod`, `oracle-sdlc`, etc.

Next, login to ECR. 

```
aws ecr-public get-login-password --region us-east-1 --profile web-sdlc | docker login --username AWS --password-stdin public.ecr.aws
```

Note that you will need to change the region to `us-west-2` for any prod cluster. 

Next, build the container and push:

```
docker build . -t public.ecr.aws/v0j6k5v6/ecc-verifier:0.0.1 && docker push public.ecr.aws/v0j6k5v6/ecc-verifier:0.0.1
```

### Make a Pull Request to Add the Service

#### Sealed Secrets

The ECC Verifier requires a keypair. We want to keep this keypair a secret from the public (this repo is public). So we use the k8s sealed-secrets controller, which encrypts the keypair such that only the cluster can read and mount it
to the container.

You may need to install the `kubeseal` utility locally.

Make sure you're connected to the right cluster with kubectl. Kubeseal is cluster specific:

```
aws eks --region us-east-1 update-kubeconfig  --name web-cluster-sdlc --profile web-sdlc
```

Now crate the sealed secret

```
cat /path/to/keypair.json | kubectl create secret generic ecc-verifier-keypair -n helium --dry-run=client --from-file=keypair.json=/dev/stdin -o yaml > ecc-verifier-keypair.yaml

kubeseal <ecc-verifier-keypair.yaml -o json >sealed-ecc-verifier-keypair.yaml -oyaml

rm ecc-verifier-keypair.yaml
```

Make a PR into this repo to add the service. For ECC Verifier, you can see this example:

https://github.com/helium/helium-foundation-k8s/pull/4

### Merge and Deploy

Once the PR is merged into master, Argo should pick it up. This can take up to 5 minutes,
but you can accelerate by clicking the "Refresh" button in argo. To log into argo, first visit the cluster-specific
argo. 

| Url | Cluster |
|-----|---------|
|https://argo.oracle.test-helium.com/| oracle-sdlc |
|https://argo.web.test-helium.com/ | web-sdlc |
|https://argo.oracle.helium.io/| oracle-prod |
|https://argo.web.helium.io/ | web-prod |


The argo username is admin, the password can be acquired by running:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

You'll usually want to check the argo interface to see if your changes deployed succesfully. 

### Debugging

You can view logs inside of Argo. Alternatively, you can use kubectl to debug. Set your kubeconfig to the cluster:


```
aws eks --region us-east-1 update-kubeconfig  --name web-cluster-sdlc --profile web-sdlc
```


Now get pods:

```
kubectl get pods -n helium
```

```
NAME                                 READY   STATUS    RESTARTS         AGE
ecc-verifier-79c6645fcc-sfbft        1/1     Running   0                35s
faucet-c95c6c865-sb9xt               1/1     Running   0                24d
metadata-76c578db8b-xw7n4            1/1     Running   0                38d
migration-service-57f69c949d-vp472   1/1     Running   0                3d20h
onboarding-server-67f768dd77-r9z9z   1/1     Running   0                6d22h
solana-monitor-5875f499b8-ck2zj      1/1     Running   130 (3d6h ago)   33d
vsr-metadata-68875c69f6-8zmwx        1/1     Running   0                38d
```

You can then get logs from the pod:


```
kubectl logs -f -n helium ecc-verifier-79c6645fcc-sfbft
```


## Connecting to Postgres

Postgres is heavily locked down. You'll need to follow several steps to connect to postgres. The postgres is isolated
within our VPC, and is only accessible through a bastion server. Further, the postgres uses rotating credentials. 

### 1. Acquire the SSH Key

Log into the appropriate AWS account. Navigate to the Parameter Store. You can download the ssh key from there.

### 2. Whitelist your IP Address for the Security Group

Navigate to security groups. Find the `ec2-bastion-security-group`

Click Inbound Rules, then edit inbound rules to add your IP


### 3. Get the postgres URL

Go to RDS, find the postgres instance, and grab the endpoint.

### 4. Find the Bastion IP Address

Navigate to the EC2 dashboard, find the bastion server, and copy its IP address.

### 5. Use SSH to port forward the postgres to your local machine

You can use ssh to port-forward the postgres through the bastion to your local machine

```
ssh -i ~/bastion-web-sdlc -L localhost:5433:<rds-address>:5432 ubuntu@<ip-address>
```

### 6. Get the password to the postgres instance

Navigate to Secrets Store in AWS and grab the postgres user authentication information

### 7. Connect

Use the credentials from above to connect

```
psql -U web_admin -p 5433 -h localhost -d postgres -W
```