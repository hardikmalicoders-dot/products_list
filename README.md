# Products List Flutter App (BLoC Architecture)

A modern, responsive Flutter application built against the public [DummyJSON API](https://dummyjson.com).

---

## 🌟 Key Features

1. **Authentication Screen (`POST /auth/login`)**
   - Clean login interface with validation and password visibility toggle.
   - Error handling banner with clear feedback on invalid credentials.
   - **Secure Storage**: JWT access and refresh tokens stored safely using `flutter_secure_storage`.
   - **Auto-Login**: Persisted session check on app boot.

2. **Product List Screen (`GET /products`)**
   - **Loading State**: Displays loading indicator during initial fetch.
   - **Error State**: Friendly error view with retry button for failed network requests.
   - **Empty State**: Empty view with actionable reset button when search or filter returns zero items.
   - **Pull-to-Refresh**: Instant list refresh via `RefreshIndicator`.
   - **Infinite Pagination**: Scroll-based lazy loading with bottom spinner and `skip` / `limit` calculation. Stops automatically when all items are fetched.
   - **Search & Category Filtering**: Search input and category choice chips with white checkmark styling.

3. **Product Detail Screen (`GET /products/{id}`)**
   - Multi-image interactive gallery/carousel with page indicator dots.
   - Price, calculated original price, and discount percentage savings badge.
   - Stock status indicators (In Stock / Low Stock / Out of Stock).
   - Rating stars widget with numeric rating and review count.
   - Specifications & Shipping policies (Warranty, Shipping, Return Policy, SKU).
   - Full list of customer reviews with star ratings, reviewer names, comments, and dates.

4. **Session Management & Logout**
   - Profile avatar and user name displayed in top left of App Bar, title centered, logout icon on far right.
   - Confirmation dialog on logout, clearing secure storage and resetting BLoC state.

---

## 🏗 Architecture & BLoC Pattern

The application follows the **BLoC (Business Logic Component)** pattern with Clean Architecture:

```
lib/
├── core/                   # Shared utilities, constants, theme, and network clients
│   ├── constants/          # API endpoint definitions
│   ├── network/            # HTTP ApiClient with timeout & error handling
│   ├── storage/            # Secure Storage Service wrapper
│   └── theme/              # Material 3 theme configuration
│
├── data/                   # Data sources, data models, and repository implementations
│   ├── models/             # Data models (User, AuthResponse, Product, Review, etc.)
│   └── repositories/       # Repositories for Auth & Products
│
├── bloc/                   # BLoC State Management Layer
│   ├── auth/               # AuthBloc, AuthEvent, AuthState
│   └── product/            # ProductBloc, ProductEvent, ProductState
│
└── presentation/           # UI Layer (Screens & Reusable Widgets)
    ├── screens/            # LoginScreen, ProductListScreen, ProductDetailScreen
    └── widgets/            # ProductCard, RatingStars, ReviewTile, StateViews
```

### Why BLoC Pattern?
- **Unidirectional Data Flow**: Events are dispatched from the UI, processed by BLoCs, and immutable States are emitted back.
- **Predictable State Transitions**: Completely separates UI layout from business logic, network requests, and data handling.
- **Testability**: Events and state transitions can be easily unit-tested with `bloc_test`.

---

## 🧪 BLoC Unit Tests

Unit tests are written using `bloc_test` and `mocktail` located under `test/bloc/`:

```
test/
└── bloc/
    ├── auth_bloc_test.dart      # Tests session check, login flow, errors & logout
    └── product_bloc_test.dart   # Tests product fetching, empty state, errors & reset
```

### Running Unit Tests
To run all BLoC unit tests:
```bash
flutter test
```

---

## 🔒 Security Considerations

- **Secure Storage**: Tokens (`accessToken`, `refreshToken`) are kept out of plain text / `SharedPreferences` and stored in platform-specific secure enclaves using `flutter_secure_storage`.
- **Bearer Authorization**: Authenticated HTTP requests append `Authorization: Bearer <TOKEN>` in request headers.

---

## 🚀 How to Run

1. Clone or open the repository in Flutter/Android Studio.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an iOS Simulator, Android Emulator, or Web:
   ```bash
   flutter run
   ```

---

## 🔑 Test Credentials

- **Username**: `emilys`
- **Password**: `emilyspass`
