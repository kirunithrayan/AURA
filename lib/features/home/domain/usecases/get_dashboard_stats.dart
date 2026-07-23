import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/home_repository.dart';

class GetDashboardStats {
  final HomeRepository repository;

  GetDashboardStats(this.repository);

  Future<Either<Failure, DashboardStats>> call() async {
    return await repository.getDashboardStats();
  }
}
