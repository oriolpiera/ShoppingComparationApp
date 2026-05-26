import '../../domain/entities/home_section.dart';

abstract class HomeSectionsRepository {
  Future<List<HomeSection>> listSections();
}
