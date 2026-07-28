import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int totalModules;
  final String duration;
  final double rating;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.totalModules,
    required this.duration,
    required this.rating,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    totalModules,
    duration,
    rating,
  ];
}
