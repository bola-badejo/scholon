import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Screens/notes/model/notes_model.dart';
import '../controllers/editor_controller.dart';

class EditorView extends GetView<EditorController> {
  const EditorView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildEditor(),
      bottomNavigationBar: _buildToolbar(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(controller.note.value.title)),
      actions: [
        Obx(() => controller.isSaving.value
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const SizedBox.shrink()),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: () => controller.exportToPdf(),
          tooltip: 'Export to PDF',
        ),
      ],
    );
  }
  
  Widget _buildEditor() {
    return Obx(() {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.blocks.length,
        itemBuilder: (context, index) {
          return _buildTextBlock(index);
        },
      );
    });
  }
  
  Widget _buildTextBlock(int index) {
    final block = controller.blocks[index];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block controls
          _buildBlockControls(index),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: _buildTextField(index, block),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBlockControls(int index) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_upward, size: 18),
          onPressed: () => controller.moveBlockUp(index),
          tooltip: 'Move up',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward, size: 18),
          onPressed: () => controller.moveBlockDown(index),
          tooltip: 'Move down',
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 18),
          onPressed: () => controller.removeBlock(index),
          tooltip: 'Delete block',
        ),
      ],
    );
  }
  
  Widget _buildTextField(int index, TextBlock block) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.textControllers[index],
          focusNode: controller.focusNodes[index],
          maxLines: null,
          style: _getTextStyle(block),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _getHintText(block.type),
            hintStyle: _getTextStyle(block).copyWith(color: Colors.grey),
          ),
          onTap: () => controller.focusedBlockIndex.value = index,
          onChanged: (value) {
            if (block.type == BlockType.title) {
              controller.note.update((val) {
                val?.title = value;
              });
            }
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
  
  TextStyle _getTextStyle(TextBlock block) {
    double fontSize;
    FontWeight fontWeight;
    String? fontFamily;
    
    switch (block.type) {
      case BlockType.title:
        fontSize = 24;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.subheading:
        fontSize = 20;
        fontWeight = FontWeight.w600;
        break;
      case BlockType.monospace:
        fontSize = 14;
        fontWeight = FontWeight.normal;
        fontFamily = 'Monospace';
        break;
      case BlockType.body:
      default:
        fontSize = 16;
        fontWeight = FontWeight.normal;
        break;
    }
    
    // Apply font family
    switch (block.fontFamily) {
      case FontFamily.serif:
        fontFamily = 'Serif';
        break;
      case FontFamily.monospace:
        fontFamily = 'Monospace';
        break;
      case FontFamily.poppins:
        fontFamily = 'Poppins';
        break;
      case FontFamily.roboto:
        fontFamily = 'Roboto';
        break;
      default:
        fontFamily = null;
    }
    
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      height: 1.5,
    );
  }
  
  String _getHintText(BlockType type) {
    switch (type) {
      case BlockType.title:
        return 'Title';
      case BlockType.subheading:
        return 'Subheading';
      case BlockType.monospace:
        return 'Code or monospace text';
      case BlockType.body:
      default:
        return 'Type your text here...';
    }
  }
  
  Widget _buildToolbar() {
    return Obx(() {
      final index = controller.focusedBlockIndex.value;
      if (index >= controller.blocks.length) return const SizedBox();
      
      final block = controller.blocks[index];
      
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Block type selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: BlockType.values.map((type) {
                return IconButton(
                  icon: _getBlockTypeIcon(type),
                  color: block.type == type ? Colors.blue : Colors.grey,
                  onPressed: () => controller.changeBlockType(index, type),
                  tooltip: _getBlockTypeName(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Font family selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: FontFamily.values.map((font) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_getFontFamilyName(font)),
                      selected: block.fontFamily == font,
                      onSelected: (selected) {
                        if (selected) {
                          controller.changeFontFamily(index, font);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            // Add block button
            ElevatedButton.icon(
              onPressed: () => controller.addBlock(index, BlockType.body),
              icon: const Icon(Icons.add),
              label: const Text('Add Block'),
            ),
          ],
        ),
      );
    });
  }
  
  Icon _getBlockTypeIcon(BlockType type) {
    switch (type) {
      case BlockType.title:
        return const Icon(Icons.title);
      case BlockType.subheading:
        return const Icon(Icons.subtitles);
      case BlockType.monospace:
        return const Icon(Icons.code);
      case BlockType.body:
      default:
        return const Icon(Icons.text_fields);
    }
  }
  
  String _getBlockTypeName(BlockType type) {
    return type.toString().split('.').last;
  }
  
  String _getFontFamilyName(FontFamily font) {
    return font.toString().split('.').last;
  }
}