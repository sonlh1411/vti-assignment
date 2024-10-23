BackendSSMPermissions

aws iam create-policy --policy-name BackendSSMPermissions --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=sonlh-eks --profile default --approve


eksctl create iamserviceaccount --override-existing-serviceaccounts --cluster=sonlh-eks --namespace=vti-sonlh --name=ssm-service-account --role-name SSMServiceRole --attach-policy-arn=arn:aws:iam::084375555299:policy/BackendSSMPermissions --approve --profile default --region us-east-1

kubectl annotate serviceaccount ssm-service-account -n vti-sonlh eks.amazonaws.com/role-arn=arn:aws:iam::084375555299:role/SSMServiceRole

    aws iam get-role --role-name SSMServiceRole

    aws iam update-assume-role-policy \                                                                     
  --role-name SSMServiceRole \
  --policy-document file://../update-policy.json


kubectl delete -f deployments/deployment.yaml
kubectl apply -f deployments/deployment.yaml
k get pods -n vti-sonlh
k logs backend-deployment-7f6c5cfdb-s8f6l -n vti-sonlh