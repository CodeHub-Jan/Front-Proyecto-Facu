
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:provider/provider.dart';

import '../models/Node.dart';

class PlanDeCuentasScreen extends StatefulWidget {
  const PlanDeCuentasScreen({super.key});

  @override
  State<PlanDeCuentasScreen> createState() => _PlanDeCuentasScreenState();
}

class _PlanDeCuentasScreenState extends State<PlanDeCuentasScreen> {
  static const List<TreeNode> roots = <TreeNode>[
    TreeNode(
      title: 'Root 1',
      children: <TreeNode>[
        TreeNode(
          title: 'Node 1.1',
          children: <TreeNode>[
            TreeNode(title: 'Node 1.1.1'),
            TreeNode(title: 'Node 1.1.2'),
          ],
        ),
        TreeNode(title: 'Node 1.2'),
      ],
    ),
    TreeNode(
      title: 'Root 2',
      children: <TreeNode>[
        TreeNode(
          title: 'Node 2.1',
          children: <TreeNode>[
            TreeNode(title: 'Node 2.1.1'),
          ],
        ),
        TreeNode(title: 'Node 2.2')
      ],
    ),
  ];
   late  TreeController<TreeNode> treeController;

  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var size=MediaQuery.of(context).size;
    treeController = TreeController<TreeNode>(
      roots: provider.accounts,
      childrenProvider: (TreeNode node) => node.children,
    );
    treeController.collapseAll();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text('Plan de Cuentas', style: TextStyle(color: AppColor.white),),backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          children:[
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: CustomButton(title: 'Volver a cargar planes de cuentas', icon: Icons.refresh, buttonWith: 250, onClick: () async{

                  await  provider.getCuentas();
                  },),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: CustomButton(title: 'Mostrar todas las cuentas', icon: Icons.account_tree_sharp, buttonWith: 250, onClick: (){

                    treeController.expandAll();
                  },),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: CustomButton(title: 'Ocultar todas las cuentas', icon: Icons.close, buttonWith: 250, onClick: (){
                    treeController.collapseAll();
                  },),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Container(
              width: size.width ,
              height: size.height ,
              child: TreeView<TreeNode>(
                treeController: treeController,

                nodeBuilder: (BuildContext context, TreeEntry<TreeNode> entry) {
                  return MyTreeTile(
                    key: ValueKey(entry.node),
                    entry: entry,
                    onTap: () => treeController.toggleExpansion(entry.node),
                  );
                },
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final TreeEntry<TreeNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              FolderButton(
                isOpen: entry.hasChildren ? entry.isExpanded : null,
                onPressed: entry.hasChildren ? onTap : null,
              ),
              Text(entry.node.title),
            ],
          ),
        ),
      ),
    );
  }
}