# ReClaim Frontend

## API base URL

The app now resolves its backend URL from `API_BASE_URL` when provided.

Examples:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.25:3000
```

If no override is supplied, Android emulators use `http://10.0.2.2:3000` and other targets fall back to `http://localhost:3000`.

Use the override when running on a physical device so the app can reach the backend on your machine.
