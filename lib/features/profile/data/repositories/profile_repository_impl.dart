import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/imgbb_remote_data_source.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/update_profile_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;
  final ImgbbRemoteDataSource _imgbbDataSource;
  final NetworkInfo _networkInfo;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileLocalDataSource localDataSource,
    required ImgbbRemoteDataSource imgbbDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _imgbbDataSource = imgbbDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, User>> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? birthDate,
    String? imageUrl,
    required String currentToken,
    required User currentUser,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = UpdateProfileRequestModel(
        fullName: fullName,
        emailAddress: currentUser.emailAddress,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        imageUrl: imageUrl,
      );
      final profileModel = await _remoteDataSource.updateProfile(
        request,
        token: currentToken,
      );

      final updatedUser = currentUser.copyWith(
        fullName: profileModel.fullName,
        phoneNumber: profileModel.phoneNumber,
        birthDate: profileModel.birthDate,
        imageUrl: imageUrl ?? currentUser.imageUrl,
      );

      await _localDataSource.cacheProfile(profileModel);

      return Right(updatedUser);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage({
    required File imageFile,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final imageUrl = await _imgbbDataSource.uploadImage(imageFile);
      return Right(imageUrl);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
