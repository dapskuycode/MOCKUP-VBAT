import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({required this.sharedPreferences});

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      // Simulasi delay jaringan (Mock API)
      await Future.delayed(const Duration(seconds: 2));

      // Mock validasi sederhana
      if (email.isNotEmpty && password.length >= 6) {
        final mockUser = AuthEntity(
          id: 'usr_123',
          name: 'Nawa User',
          email: email,
          token: 'mock_token_abc123',
        );

        // Simpan token ke lokal
        await sharedPreferences.setString('cached_token', mockUser.token);

        return Right(mockUser);
      } else {
        return const Left(ServerFailure('Email atau password tidak valid'));
      }
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan koneksi'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await sharedPreferences.remove('cached_token');
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Gagal menghapus sesi'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> checkAuthStatus() async {
    try {
      final token = sharedPreferences.getString('cached_token');
      if (token != null) {
        // Jika token ada, anggap user masih login (Mock)
        return const Right(
          AuthEntity(
            id: 'usr_123',
            name: 'Nawa User',
            email: 'user@vbat.id',
            token: 'mock_token_abc123',
          ),
        );
      } else {
        return const Left(CacheFailure('Sesi telah berakhir'));
      }
    } catch (e) {
      return const Left(CacheFailure('Gagal memeriksa sesi'));
    }
  }
}
