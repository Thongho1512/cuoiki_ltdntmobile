import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/auction/data/datasources/auction_remote_datasource.dart';
import 'features/auction/data/repositories/auction_repository_impl.dart';
import 'features/auction/domain/repositories/auction_repository.dart';
import 'features/auction/domain/usecases/get_auctions_usecase.dart';
import 'features/auction/domain/usecases/get_bid_history_usecase.dart';
import 'features/auction/domain/usecases/place_bid_usecase.dart';
import 'features/auction/domain/usecases/watch_auction_usecase.dart';
import 'features/auction/presentation/bloc/auction_detail/auction_detail_bloc.dart';
import 'features/auction/presentation/bloc/auction_list/auction_list_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== BLoCs ==========
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(() => AuctionListBloc(getAuctionsUseCase: sl()));

  sl.registerFactory(
    () => AuctionDetailBloc(
      watchAuctionUseCase: sl(),
      placeBidUseCase: sl(),
      getBidHistoryUseCase: sl(),
    ),
  );

  // ========== Use Cases - Auth ==========
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // ========== Use Cases - Auction ==========
  sl.registerLazySingleton(() => GetAuctionsUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuctionUseCase(sl()));
  sl.registerLazySingleton(() => PlaceBidUseCase(sl()));
  sl.registerLazySingleton(() => GetBidHistoryUseCase(sl()));

  // ========== Repositories ==========
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuctionRepository>(
    () => AuctionRepositoryImpl(remoteDataSource: sl(), firebaseAuth: sl()),
  );

  // ========== Data Sources ==========
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<AuctionRemoteDataSource>(
    () => AuctionRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // ========== External ==========
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
