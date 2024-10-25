echo "Starting update kubeconfig"
echo "Please enter your eks cluster name: (example default)"
read ekscluster
echo "Please enter your eks cluster region: (example ap-southeast-1)"
read region
echo "Please enter your AWS profile name: (example default)"
read profile
aws eks update-kubeconfig --name $ekscluster --region $region --profile $profile

echo "Verifying the eks cluster"
kubectl config current-context | grep $ekscluster  | wc -l
kubectl get namespace -A