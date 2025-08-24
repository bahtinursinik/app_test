# Flutter Product Management App

Bu proje Flutter ile geliştirilmiş bir ürün yönetim uygulamasıdır. Hive ile yerel veri saklama ve BLoC pattern ile durum yönetimi kullanır. Uygulama, ürünlerin eklenmesi, güncellenmesi, silinmesi ve listelenmesi gibi temel işlevleri içerir. Ayrıca unit testler, widget testler ve servis testleri ile kapsamlı bir test altyapısına sahiptir.


---

## Özellikler

- Ürün listeleme, ekleme, güncelleme ve silme  
- Hive ile yerel veri saklama  
- BLoC ile durum yönetimi  
- Unit testler ile iş mantığı testleri  
- Widget testler ile UI testleri  
- Servis testleri ile API etkileşimlerinin test edilmesi

---

## Gereksinimler

- Flutter SDK ≥ 3.x  
- Dart ≥ 3.x  
- Paketler:
  - `hive`
  - `flutter_bloc`
  - `mocktail`
  - `bloc_test`
  - `flutter_test`
  - `http`
  - `build_runner` (Hive adapter için)

---

## Kurulum

1. Depoyu klonlayın ve bağımlılıkları yükleyin:

```bash
git clone https://github.com/bahtinursinik/app_test.git
cd app_test
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Testleri Çalıştırma

### Tüm testler

```bash
flutter test
```

### Unit Testler

```bash
flutter test test/unit/product_bloc_test.dart
flutter test test/unit/product_repository_test.dart
flutter test test/unit/product_service_test.dart
```

### Widget Testler

```bash
flutter test test/widget/product_card_and_form_dialog_widget_test.dart
flutter test test/widget/product_textfield_widget_test.dart
```

