import dotenv from "dotenv";
dotenv.config();

import request from "supertest";
import { expect } from "chai";
import App from "../src/app.js";

describe("Auth API", () => {
  const agent = request.agent(App);
  const uniqueId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const testEmail = `test-user-${uniqueId}@example.com`;
  const testPassword = "MyTestPass!23";

  before(async () => {
    await agent.post("/auth/user").send({
      fullName: "Reg User",
      email: testEmail,
      password: testPassword,
    });
  });

  it("logs in the user", async () => {
    const res = await agent.post("/auth/login").send({
      email: testEmail,
      password: testPassword,
    });

    expect(res.status).to.equal(200);
    expect(res.body).to.have.property("accessToken");
    expect(res.headers["set-cookie"]).to.exist;
  });

  it("refreshes access token using refresh cookie", async () => {
    const login = await agent.post("/auth/login").send({
      email: testEmail,
      password: testPassword,
    });

    expect(login.status).to.equal(200);

    const refreshRes = await agent.post("/auth/refresh").send();
    expect(refreshRes.status).to.equal(200);
    expect(refreshRes.body).to.have.property("accessToken");
  });
});
