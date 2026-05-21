import dotenv from "dotenv";
import request from "supertest";
import { expect } from "chai";
import App from "../src/app.js";

dotenv.config();

describe("Users API", () => {
  const api = request(App);
  const uniqueId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const testEmail = `user-${uniqueId}@example.com`;
  const updatedEmail = `user-updated-${uniqueId}@example.com`;

  let userId: number;

  it("creates a user", async () => {
    const res = await api.post("/users").send({
      fullName: "Users Test",
      email: testEmail,
      password: "MyTestPass!23",
      role: "user",
    });

    expect(res.status).to.equal(201);
    expect(res.body.user).to.include({ email: testEmail, role: "user" });
    userId = res.body.user.id;
  });

  it("lists users", async () => {
    const res = await api.get("/users");

    expect(res.status).to.equal(200);
    expect(res.body.users).to.be.an("array");
    expect(res.body.users.some((user: { id: number }) => user.id === userId)).to.equal(true);
  });

  it("gets a user by id", async () => {
    const res = await api.get(`/users/${userId}`);

    expect(res.status).to.equal(200);
    expect(res.body.user).to.include({ id: userId, email: testEmail });
  });

  it("updates a user", async () => {
    const res = await api.put(`/users/${userId}`).send({
      fullName: "Users Test Updated",
      email: updatedEmail,
    });

    expect(res.status).to.equal(200);
    expect(res.body.user).to.include({ id: userId, email: updatedEmail, fullName: "Users Test Updated" });
  });

  it("deletes a user", async () => {
    const res = await api.delete(`/users/${userId}`);

    expect(res.status).to.equal(200);
    expect(res.body.message).to.equal("User deleted successfully");
  });
});