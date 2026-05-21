# Backend Integration Guide

This document describes the backend HTTP API the frontend can use right now.

## Base Notes

- The backend expects JSON request bodies for write operations.
- All feature routes are currently open. Middleware for auth/authorization can be added later without changing the route structure.
- The API follows a camelCase request body style, while the database uses snake_case columns internally.
- List endpoints currently return all rows and are sorted by newest first.
- Auth refresh uses an HTTP-only cookie named `refreshToken`, so frontend requests that rely on refresh must send credentials.

## Common Response Patterns

Success responses usually look like one of these:

```json
{ "message": "..." }
```

```json
{ "message": "...", "user": { ... } }
```

```json
{ "message": "...", "item": { ... } }
```

```json
{ "message": "...", "claim": { ... } }
```

```json
{ "users": [ ... ] }
```

```json
{ "items": [ ... ] }
```

```json
{ "claims": [ ... ] }
```

Common error responses:

```json
{ "message": "Bad request message" }
```

```json
{ "message": "Internal server error" }
```

## Auth

Base path: `/auth`

### Register a User

`POST /auth/user`

Request body:

```json
{
  "fullName": "Jane Doe",
  "email": "jane@example.com",
  "password": "MySecret123!"
}
```

Response `201`:

```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "full_name": "Jane Doe",
    "email": "jane@example.com"
  },
  "accessToken": "jwt-access-token"
}
```

Notes:

- A `refreshToken` cookie is set automatically.
- The returned `user` object uses `full_name` in this auth flow.

### Login

`POST /auth/login`

Request body:

```json
{
  "email": "jane@example.com",
  "password": "MySecret123!"
}
```

Response `200`:

```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "full_name": "Jane Doe",
    "email": "jane@example.com",
    "role": "user"
  },
  "accessToken": "jwt-access-token"
}
```

Notes:

- A `refreshToken` cookie is set automatically.

### Refresh Access Token

`POST /auth/refresh`

Request body:

```json
{}
```

Response `200`:

```json
{
  "accessToken": "new-jwt-access-token"
}
```

Notes:

- No body is required.
- Frontend requests must send cookies so the server can read `refreshToken`.

### Get User by ID

`GET /auth/user/:id`

Response `200`:

```json
{
  "user": {
    "id": 1,
    "full_name": "Jane Doe",
    "email": "jane@example.com"
  }
}
```

### Update User by ID

`PUT /auth/user/:id`

Request body:

```json
{
  "fullName": "Jane Updated",
  "email": "jane.updated@example.com"
}
```

Response `200`:

```json
{
  "message": "User updated successfully",
  "user": {
    "id": 1,
    "full_name": "Jane Updated",
    "email": "jane.updated@example.com"
  }
}
```

## Users CRUD

Base path: `/users`

This is the full CRUD surface for the users table.

### List Users

`GET /users`

Response `200`:

```json
{
  "users": [
    {
      "id": 1,
      "fullName": "Jane Doe",
      "email": "jane@example.com",
      "role": "user",
      "createdAt": "2026-05-22T10:00:00.000Z"
    }
  ]
}
```

### Create User

`POST /users`

Request body:

```json
{
  "fullName": "Jane Doe",
  "email": "jane@example.com",
  "password": "MySecret123!",
  "role": "user"
}
```

Notes:

- `role` is optional and defaults to `user`.
- Allowed roles: `user`, `admin`.

Response `201`:

```json
{
  "message": "User created successfully",
  "user": {
    "id": 1,
    "fullName": "Jane Doe",
    "email": "jane@example.com",
    "role": "user",
    "createdAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Get User by ID

`GET /users/:id`

Response `200`:

```json
{
  "user": {
    "id": 1,
    "fullName": "Jane Doe",
    "email": "jane@example.com",
    "role": "user",
    "createdAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Update User

`PUT /users/:id`

Request body can include any of these fields:

```json
{
  "fullName": "Jane Updated",
  "email": "jane.updated@example.com",
  "password": "NewSecret123!",
  "role": "admin"
}
```

Notes:

- At least one field must be sent.
- Allowed roles: `user`, `admin`.

Response `200`:

```json
{
  "message": "User updated successfully",
  "user": {
    "id": 1,
    "fullName": "Jane Updated",
    "email": "jane.updated@example.com",
    "role": "admin",
    "createdAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Delete User

`DELETE /users/:id`

Response `200`:

```json
{
  "message": "User deleted successfully"
}
```

## Items CRUD

Base path: `/items`

### List Items

`GET /items`

Response `200`:

```json
{
  "items": [
    {
      "id": 1,
      "title": "Lost Wallet",
      "description": "Black leather wallet",
      "categoryId": 2,
      "location": "Main Hall",
      "dateFound": "2026-05-21",
      "imageUrl": null,
      "verificationQuestion": "What is inside?",
      "verificationAnswer": "Two cards",
      "hiddenDetails": null,
      "status": "available",
      "postedBy": 1,
      "createdAt": "2026-05-22T10:00:00.000Z",
      "updatedAt": "2026-05-22T10:00:00.000Z"
    }
  ]
}
```

### Create Item

`POST /items`

Request body:

```json
{
  "title": "Lost Wallet",
  "description": "Black leather wallet",
  "categoryId": 2,
  "location": "Main Hall",
  "dateFound": "2026-05-21",
  "imageUrl": "https://example.com/wallet.jpg",
  "verificationQuestion": "What is inside?",
  "verificationAnswer": "Two cards",
  "hiddenDetails": "Blue card holder",
  "status": "available",
  "postedBy": 1
}
```

Notes:

- Required fields: `title`, `description`, `location`, `dateFound`, `verificationQuestion`, `verificationAnswer`, `postedBy`.
- Optional fields: `categoryId`, `imageUrl`, `hiddenDetails`, `status`.
- Allowed statuses: `available`, `claimed`, `resolved`.
- `dateFound` should be sent as an ISO date string like `YYYY-MM-DD`.

Response `201`:

```json
{
  "message": "Item created successfully",
  "item": {
    "id": 1,
    "title": "Lost Wallet",
    "description": "Black leather wallet",
    "categoryId": 2,
    "location": "Main Hall",
    "dateFound": "2026-05-21",
    "imageUrl": "https://example.com/wallet.jpg",
    "verificationQuestion": "What is inside?",
    "verificationAnswer": "Two cards",
    "hiddenDetails": "Blue card holder",
    "status": "available",
    "postedBy": 1,
    "createdAt": "2026-05-22T10:00:00.000Z",
    "updatedAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Get Item by ID

`GET /items/:id`

Response `200`:

```json
{
  "item": {
    "id": 1,
    "title": "Lost Wallet",
    "description": "Black leather wallet",
    "categoryId": 2,
    "location": "Main Hall",
    "dateFound": "2026-05-21",
    "imageUrl": null,
    "verificationQuestion": "What is inside?",
    "verificationAnswer": "Two cards",
    "hiddenDetails": null,
    "status": "available",
    "postedBy": 1,
    "createdAt": "2026-05-22T10:00:00.000Z",
    "updatedAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Update Item

`PUT /items/:id`

Request body can include any of these fields:

```json
{
  "title": "Found Wallet",
  "description": "Updated description",
  "categoryId": 2,
  "location": "Reception",
  "dateFound": "2026-05-22",
  "imageUrl": "https://example.com/wallet-new.jpg",
  "verificationQuestion": "What color is it?",
  "verificationAnswer": "Black",
  "hiddenDetails": "Blue card holder",
  "status": "claimed",
  "postedBy": 1
}
```

Notes:

- At least one field must be sent.
- Allowed statuses: `available`, `claimed`, `resolved`.

Response `200`:

```json
{
  "message": "Item updated successfully",
  "item": {
    "id": 1,
    "title": "Found Wallet",
    "description": "Updated description",
    "categoryId": 2,
    "location": "Reception",
    "dateFound": "2026-05-22",
    "imageUrl": "https://example.com/wallet-new.jpg",
    "verificationQuestion": "What color is it?",
    "verificationAnswer": "Black",
    "hiddenDetails": "Blue card holder",
    "status": "claimed",
    "postedBy": 1,
    "createdAt": "2026-05-22T10:00:00.000Z",
    "updatedAt": "2026-05-22T10:05:00.000Z"
  }
}
```

### Delete Item

`DELETE /items/:id`

Response `200`:

```json
{
  "message": "Item deleted successfully"
}
```

## Claims CRUD

Base path: `/claims`

### List Claims

`GET /claims`

Response `200`:

```json
{
  "claims": [
    {
      "id": 1,
      "itemId": 1,
      "claimantId": 2,
      "answerAttempt": "Two cards",
      "status": "pending",
      "reviewNote": null,
      "createdAt": "2026-05-22T10:00:00.000Z",
      "updatedAt": "2026-05-22T10:00:00.000Z"
    }
  ]
}
```

### Create Claim

`POST /claims`

Request body:

```json
{
  "itemId": 1,
  "claimantId": 2,
  "answerAttempt": "Two cards",
  "status": "pending",
  "reviewNote": null
}
```

Notes:

- Required fields: `itemId`, `claimantId`, `answerAttempt`.
- Optional fields: `status`, `reviewNote`.
- Allowed statuses: `pending`, `approved`, `rejected`, `withdrawn`.

Response `201`:

```json
{
  "message": "Claim created successfully",
  "claim": {
    "id": 1,
    "itemId": 1,
    "claimantId": 2,
    "answerAttempt": "Two cards",
    "status": "pending",
    "reviewNote": null,
    "createdAt": "2026-05-22T10:00:00.000Z",
    "updatedAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Get Claim by ID

`GET /claims/:id`

Response `200`:

```json
{
  "claim": {
    "id": 1,
    "itemId": 1,
    "claimantId": 2,
    "answerAttempt": "Two cards",
    "status": "pending",
    "reviewNote": null,
    "createdAt": "2026-05-22T10:00:00.000Z",
    "updatedAt": "2026-05-22T10:00:00.000Z"
  }
}
```

### Update Claim

`PUT /claims/:id`

Request body can include any of these fields:

```json
{
  "itemId": 1,
  "claimantId": 2,
  "answerAttempt": "Updated answer",
  "status": "approved",
  "reviewNote": "Verified by admin"
}
```

Notes:

- At least one field must be sent.
- Allowed statuses: `pending`, `approved`, `rejected`, `withdrawn`.

Response `200`:

```json
{
  "message": "Claim updated successfully",
  "claim": {
    "id": 1,
    "itemId": 1,
    "claimantId": 2,
    "answerAttempt": "Updated answer",
    "status": "approved",
    "reviewNote": "Verified by admin",
    "createdAt": "2026-05-22T10:00:00.000Z",
    "updatedAt": "2026-05-22T10:05:00.000Z"
  }
}
```

### Delete Claim

`DELETE /claims/:id`

Response `200`:

```json
{
  "message": "Claim deleted successfully"
}
```

## Frontend Integration Tips

- Use `fetch` or Axios with `Content-Type: application/json` for all POST and PUT calls.
- For auth refresh flows, send credentials so cookies are included.
- Keep the request names aligned with the backend contract: `fullName`, `categoryId`, `dateFound`, `answerAttempt`, and so on.
- If the UI needs the authenticated refresh flow, use the `/auth/login` or `/auth/user` response `accessToken` for bearer auth on the client side.
