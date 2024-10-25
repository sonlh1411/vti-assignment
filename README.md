# Variables
POLICY_NAME=BackendSSMPermissions
ROLE_NAME=SSMServiceRole
AWS_REGION=us-east-2
AWS_CLUSTER=sonlh-eks
POLICY_DOCUMENT=file://iam_policy.json
NAMESPACE=vti-sonlh
EKS_SERVICE_ACCOUNT=ssm-service-account
IAM_ID=084375555299
PROFILE=default
IAM_POLICY_ARN=arn:aws:iam::084375555299:policy/BackendSSMPermissions
EKS_ROLE_ARN=eks.amazonaws.com/role-arn=arn:aws:iam::084375555299:role/SSMServiceRole


# Update Role Steps
1. Create k8 service account
kubectl create serviceaccount $EKS_SERVICE_ACCOUNT -n $NAMESPACE

2. Download IAM_POLICY
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

3. Update IAM Policy with SSM, ECR, RDS roles
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:<REGION>:<ACCOUNT_ID>:parameter/<PATH_TO_PARAMETERS>/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBInstances", 
                "sts:AssumeRoleWithWebIdentity"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Resource": "arn:aws:ecr:<REGION>:<ACCOUNT_ID>:repository/<ECR_REPOSITORY_NAME>"
        }
    ]
}
```

4. Create IAM Policy with document download in step 2 and 3
aws iam create-policy --policy-name $POLICY_NAME --policy-document $POLICY_DOCUMENT

5. Create an IAM OIDC Provider
eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster=$AWS_CLUSTER --profile $PROFILE --approve

6. Create the IAM Role
eksctl create iamserviceaccount \
    --cluster=$AWS_CLUSTER \
    --namespace=$NAMESPACE \
    --name=$EKS_SERVICE_ACCOUNT \
    --role-name $ROLE_NAME \
    --attach-policy-arn=$IAM_POLICY_ARN \
    --region $AWS_REGION \
    --profile default \
    --override-existing-serviceaccounts \
    --approve

# AWS command

kubectl annotate serviceaccount ssm-service-account -n vti-sonlh eks.amazonaws.com/role-arn=arn:aws:iam::084375555299:role/SSMServiceRole

aws iam get-role --role-name SSMServiceRole

aws iam update-assume-role-policy --role-name SSMServiceRole --policy-document file://update-policy.json