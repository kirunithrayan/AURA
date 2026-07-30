import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/home_repository.dart';

class GetDashboardStats {

  GetDashboardStats(this.repository);
  final HomeRepository repository;

  Future<Either<Failure, DashboardStats>> call() async => await repository.getDashboardStats();
}
