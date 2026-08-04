import '../../core/constants/app_assets.dart';
import '../../domain/model/category.dart';
import '../dto/category_dto.dart';

abstract final class CategoryMapper {
  static Category toDomain(CategoryDto dto) => Category(
        id: dto.id,
        name: dto.name,
        imageUrl: dto.image.trim().isEmpty
            ? AppAssets.seeded('cat-${dto.name}', w: 300, h: 300)
            : dto.image,
        sortOrder: dto.sortOrder,
        foodTypeScope: dto.foodTypeScope,
      );

  static List<Category> toDomainList(List<CategoryDto> dtos) =>
      dtos.where((d) => d.isActive).map(toDomain).toList()
        ..sort((a, b) {
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
        });
}
