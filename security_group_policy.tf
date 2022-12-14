resource "kubectl_manifest" "rds-access-security-group-policy" {
    yaml_body = <<YAML
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
metadata:
  name: rds-access-security-group-policy
  namespace: helium
spec:
  podSelector: 
    matchLabels: 
      security-group: rds-access
  securityGroups:
    groupIds:
      - "${data.aws_security_group.rds_access_security_group.id}"
      - "${data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id}"
YAML
}