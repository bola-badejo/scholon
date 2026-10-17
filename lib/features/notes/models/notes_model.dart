import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum BlockType { title, subheading, body, monospace }

enum FontFamily { sansSerif, serif, monospace, poppins, roboto }

class TextBlock {
  final BlockType type;
  final String text;
  final FontFamily fontFamily;
  
  TextBlock({
    required this.type,
    required this.text,
    this.fontFamily = FontFamily.sansSerif,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'text': text,
      'fontFamily': fontFamily.name,
    };
  }
  
  factory TextBlock.fromMap(Map<String, dynamic> map) {
    return TextBlock(
      type: BlockType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BlockType.body,
      ),
      text: map['text'] ?? '',
      fontFamily: FontFamily.values.firstWhere(
        (e) => e.name == map['fontFamily'],
        orElse: () => FontFamily.sansSerif,
      ),
    );
  }
  
  // Add copyWith method for TextBlock
  TextBlock copyWith({
    BlockType? type,
    String? text,
    FontFamily? fontFamily,
  }) {
    return TextBlock(
      type: type ?? this.type,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class Note {
  String? id;
  String userId;
  String title;
  List<TextBlock> blocks;
  DateTime createdAt;
  DateTime updatedAt;
  
  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.blocks,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Note.createNew(String userId) {
    final now = DateTime.now();
    return Note(
      userId: userId,
      title: 'Untitled Note',
      blocks: [
        TextBlock(type: BlockType.title, text: 'Untitled Note'),
        TextBlock(type: BlockType.body, text: ''),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'blocks': blocks.map((block) => block.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Untitled',
      blocks: (map['blocks'] as List<dynamic>?)
          ?.map((block) => TextBlock.fromMap(block as Map<String, dynamic>))
          .toList() ??
          [TextBlock(type: BlockType.body, text: '')],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  // Add copyWith method for Note
  Note copyWith({
    String? id,
    String? userId,
    String? title,
    List<TextBlock>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  String get previewText {
    final bodyBlock = blocks.firstWhere(
      (block) => block.type == BlockType.body,
      orElse: () => blocks.firstWhere(
        (block) => block.type != BlockType.title,
        orElse: () => TextBlock(type: BlockType.body, text: ''),
      ),
    );
    return bodyBlock.text.length > 100 
        ? '${bodyBlock.text.substring(0, 100)}...' 
        : bodyBlock.text;
  }
}