# Backend Integration Guide

This document reflects the current backend API used by the frontend.

## Base Notes

- Write operations expect JSON request bodies.
- Authenticated routes expect a bearer token in `Authorization: Bearer <token>`.
- Refresh flows use the `refreshToken` HTTP-only cookie, so clients must send credentials.
- The API uses camelCase in requests and responses; the database stays snake_case internally.
- Claims now belong to the authenticated user, and claim review compares `answerAttempt` with the item’s `verification_answer`.

## Common Responses

Success responses typically look like one of these:

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

Common errors:

```json
{ "message": "Authentication required" }
```

```json
{ "message": "You do not have permission to perform this action" }
```

```json
{ "message": "Internal server error" }
```

## Auth

Base path: `/auth`

### Register

`POST /auth/register`

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
    "email": "jane@example.com",
    "role": "user"
  },
  "token": "jwt-access-token",
  "accessToken": "jwt-access-token"
}
```

Notes:

- A `refreshToken` cookie is set automatically.
- `POST /auth/user` is still accepted for backward compatibility.

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

### Refresh Token

`POST /auth/refresh`

Response `200`:

```json
{ "accessToken": "new-jwt-access-token" }
```

### Current User

`GET /auth/me`

Response `200`:

```json
{
  "user": {
    "id": 1,
    "full_name": "Jane Doe",
    "email": "jane@example.com",
    "role": "user"
  }
}
```

## Users

Base path: `/users`

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

### Get User

`GET /users/:id`

### Update User

`PUT /users/:id`

Request body can include:

```json
{
  "fullName": "Jane Updated",
  "email": "jane.updated@example.com",
  "password": "NewSecret123!",
  "role": "admin"
}
```

### Delete User

`DELETE /users/:id`

## Items

Base path: `/items`

### List Items

`GET /items`

Auth required.

Response `200` excludes `verificationAnswer`:

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
      "hiddenDetails": null,
      "status": "available",
      "postedBy": 1,
      "createdAt": "2026-05-22T10:00:00.000Z",
      "updatedAt": "2026-05-22T10:00:00.000Z"
    }
  ]
}
```

### Admin List

`GET /items/admin`

Auth + admin required.

Response includes `verificationAnswer`.

### Create Item

`POST /items`

Auth required.

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
  "status": "available"
}
```

Notes:

- `postedBy` is taken from the authenticated user.
- Allowed statuses: `available`, `claimed`, `resolved`.

### Get Item

`GET /items/:id`

Auth required.

- Normal users get the public view.
- Admins get the full item including `verificationAnswer`.

### Update Item

`PUT /items/:id`

Auth required.

- Owners or admins can update.
- Normal users cannot update someone else’s item.

### Delete Item

`DELETE /items/:id`

Auth required.

- Owners or admins can delete.

## Claims

Base path: `/claims`

### List Claims

`GET /claims`

Auth required.

- Normal users see only their own claims.
- Admins see all claims.

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

Auth required.

Request body:

```json
{
  "itemId": 1,
  "answerAttempt": "Two cards",
  "status": "pending"
}
```

Notes:

- Claims are created for the authenticated user.
- New claims must start as `pending`.
- `claimantId` is ignored if sent and must match the authenticated user.

### Get Claim

`GET /claims/:id`

Auth required.

- Owners or admins can read the claim.

### Update Claim

`PUT /claims/:id`

Auth required.

- Owners can withdraw their own claim.
- Admins can update claim details or status.

### Review Claim

`PATCH /claims/:id/approve`

Auth + admin required.

Request body:

```json
{ "reviewNote": "Verified and approved" }
```

Behavior:

- The backend compares `claims.answer_attempt` with `items.verification_answer`.
- If they match, the claim becomes `approved`.
- If they do not match, the claim becomes `rejected`.
- `reviewNote` is saved when provided.

### Alias Review Route

`PATCH /claims/:id/review`

Same behavior as `/approve`.

### Delete Claim

`DELETE /claims/:id`

Auth required.

- Owners or admins can delete.

## Frontend Notes

- Send `Authorization: Bearer <accessToken>` for protected endpoints.
- Use `credentials: 'include'` or equivalent when calling refresh.
- For item detail screens, do not expect `verificationAnswer` unless the caller is an admin.
