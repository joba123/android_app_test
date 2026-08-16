import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Misch-Modus', () {
    test('legt sich weder auf ein Modul noch auf ein Thema fest', () {
      const scope = PracticeScope.mixed();

      expect(scope.isMixed, isTrue);
      expect(scope.module, isNull);
      expect(scope.subCategory, isNull);
      expect(scope.subCategories, isEmpty);
      expect(scope.label, 'Alle Kategorien gemischt');
    });
  });

  group('Ein ganzes Modul', () {
    test('setzt das Modul, aber kein einzelnes Thema', () {
      const scope = PracticeScope.module(TrainingModule.logic);

      expect(scope.isMixed, isFalse);
      expect(scope.module, TrainingModule.logic);
      expect(scope.subCategory, isNull);
      expect(scope.subCategories, isEmpty);
      expect(scope.label, 'Logisches Denken · alle Themen');
      expect(scope.shortLabel, 'Logik');
    });
  });

  group('Ein einzelnes Thema', () {
    test('leitet das Modul aus dem Thema ab', () {
      final scope = PracticeScope.subCategory(SubCategory.percentage);

      expect(scope.module, TrainingModule.math);
      expect(scope.subCategory, SubCategory.percentage);
      expect(scope.subCategories, [SubCategory.percentage]);
      expect(scope.shortLabel, 'Prozentrechnung');
    });

    test('das abgeleitete Modul stimmt für jedes Thema', () {
      for (final subCategory in SubCategory.values) {
        final scope = PracticeScope.subCategory(subCategory);
        expect(scope.module, subCategory.module);
      }
    });
  });

  group('Gleichheit', () {
    test('gleiche Auswahl ist gleich', () {
      expect(const PracticeScope.mixed(), const PracticeScope.mixed());
      expect(
        const PracticeScope.module(TrainingModule.math),
        const PracticeScope.module(TrainingModule.math),
      );
      expect(
        PracticeScope.subCategory(SubCategory.spelling),
        PracticeScope.subCategory(SubCategory.spelling),
      );
    });

    test('unterschiedliche Auswahl ist ungleich', () {
      expect(
        const PracticeScope.module(TrainingModule.math),
        isNot(const PracticeScope.module(TrainingModule.logic)),
      );
      expect(
        const PracticeScope.mixed(),
        isNot(const PracticeScope.module(TrainingModule.math)),
      );
      // Ein einzelnes Thema ist nicht dasselbe wie sein ganzes Modul.
      expect(
        PracticeScope.subCategory(SubCategory.arithmetic),
        isNot(const PracticeScope.module(TrainingModule.math)),
      );
    });

    test('gleiche Auswahl teilt sich den hashCode', () {
      expect(
        PracticeScope.subCategory(SubCategory.grammar).hashCode,
        PracticeScope.subCategory(SubCategory.grammar).hashCode,
      );
    });
  });
}
