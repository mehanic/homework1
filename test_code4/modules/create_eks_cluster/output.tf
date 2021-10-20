output "node_group" {
    value = {}
    depends_on = [aws_eks_node_group.node_group]
}