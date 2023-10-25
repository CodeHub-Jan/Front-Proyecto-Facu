class TreeNode {
  const TreeNode({
    required this.title,
    this.children = const <TreeNode>[],
  });

  final String title;
  final List<TreeNode> children;
}