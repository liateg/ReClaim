export type UserRole = "user" | "admin";

export interface AuthTokenPayload {
  id: number;
  full_name: string;
  email: string;
  role: UserRole;
}