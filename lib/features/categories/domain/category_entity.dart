import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'category_entity.g.dart';

@HiveType(typeId: 2)
class CategoryEntity extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  CategoryEntity({
   required this.id,
   required this.name,
   required this.colorValue
});
  Color get color => Color(colorValue);
}