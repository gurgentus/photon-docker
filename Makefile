APP_NAME = photon
APP_VERSION = dev

AWS_ECR_ACCOUNT_ID = 870415787163
AWS_ECR_REGION = us-east-1
AWS_ECR_REPO = $(APP_NAME)

TAG = $(APP_VERSION)

# Add a variable for optional arguments, defaulting to empty
DOCKER_ARGS ?=

.PHONY : docker/build docker/push docker/run docker/test

docker/buildl :
	docker build --no-cache -t $(APP_NAME):$(APP_VERSION) .

docker/build :
	docker build --no-cache -t $(APP_NAME):$(APP_VERSION) .

docker/rmi : 
 docker rmi --force $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO):$(TAG)

docker/push : docker/build
	aws ecr get-login-password --region $(AWS_ECR_REGION) | docker login --username AWS --password-stdin $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com
	docker tag $(APP_NAME):$(APP_VERSION) $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO):$(TAG)
	docker push $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO):$(TAG)

docker/run :
	docker run -it --rm -v /mnt/ebs/photon_data:/photon/photon_data -p 2322:2322 \
		$(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO):$(TAG) \
		$(DOCKER_ARGS)

docker/localrun:
	docker run -it --restart always -v /mnt/ebs/photon_data:/photon/photon_data -p 2322:2322 $(APP_NAME):$(APP_VERSION)

docker/test :
	curl -XGET 'http://localhost:2322/api/?q=Berlin'