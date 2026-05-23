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
        await agent.post("/auth/register").send({
            name: "Reg User",
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
    it("returns the current user from the access token", async () => {
        const login = await agent.post("/auth/login").send({
            email: testEmail,
            password: testPassword,
        });
        expect(login.status).to.equal(200);
        const meRes = await agent
            .get("/auth/me")
            .set("Authorization", `Bearer ${login.body.accessToken}`);
        expect(meRes.status).to.equal(200);
        expect(meRes.body.user).to.have.property("id");
        expect(meRes.body.user).to.have.property("role");
    });
});
//# sourceMappingURL=auth.test.js.map