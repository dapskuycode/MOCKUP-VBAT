import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses() async {
    try {
      // Simulasi delay fetch data
      await Future.delayed(const Duration(seconds: 2));

      // Data Mock Kursus
      final mockCourses = [
        const CourseEntity(
          id: 'c1',
          title: 'Masterclass Micro-Soldering',
          description:
              'Pelajari teknik dasar hingga mahir dalam soldering komponen mikro.',
          imageUrl: 'assets/images/course_1.png',
          totalModules: 12,
          duration: '3h 45m',
          rating: 4.9,
        ),
        const CourseEntity(
          id: 'c2',
          title: 'Diagnosis IC Power iPhone',
          description:
              'Cara mendiagnosis dan memperbaiki IC Power pada berbagai seri iPhone.',
          imageUrl: 'assets/images/course_1.png',
          totalModules: 8,
          duration: '2h 10m',
          rating: 4.8,
        ),
        const CourseEntity(
          id: 'c3',
          title: 'Ganti Kaca LCD Tanpa Bubbles',
          description:
              'Tips dan trik menggunakan mesin laminasi OCA untuk hasil sempurna.',
          imageUrl: 'assets/images/course_1.png',
          totalModules: 5,
          duration: '1h 20m',
          rating: 4.7,
        ),
      ];

      return Right(mockCourses);
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data kursus'));
    }
  }
}
