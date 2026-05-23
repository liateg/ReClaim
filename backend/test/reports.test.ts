import dotenv from "dotenv";
import request from "supertest";
import { expect } from "chai";
import App from "../src/app.js";

dotenv.config();

describe("Reports API", () => {
  const api = request(App);
  const uniqueId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const userEmail = `report-user-${uniqueId}@example.com`;
  const adminEmail = `report-admin-${uniqueId}@example.com`;

  let userId: number;
  let userToken: string;
  let adminId: number;
  let adminToken: string;
  let itemId: number;
  let reportId: number;

  before(async () => {
    const userRes = await api.post("/auth/register").send({
      name: "Report User",
      email: userEmail,
      password: "MyTestPass!23",
    });
    expect(userRes.status).to.equal(201);
    userId = userRes.body.user.id;
    userToken = userRes.body.accessToken;

    const adminRes = await api.post("/users").send({
      fullName: "Report Admin",
      email: adminEmail,
      password: "MyTestPass!23",
      role: "admin",
    });
    expect(adminRes.status).to.equal(201);
    adminId = adminRes.body.user.id;

    const loginRes = await api.post("/auth/login").send({
      email: adminEmail,
      password: "MyTestPass!23",
    });
    expect(loginRes.status).to.equal(200);
    adminToken = loginRes.body.accessToken;

    const itemRes = await api
      .post("/items")
      .set("Authorization", `Bearer ${userToken}`)
      .send({
        title: `Report Item ${uniqueId}`,
        description: "Item for report tests",
        location: "Test Bench",
        dateFound: "2026-05-21",
        verificationQuestion: "What color?",
        verificationAnswer: "green",
        status: "available",
      });

    expect(itemRes.status).to.equal(201);
    itemId = itemRes.body.item.id;
  });

  it("creates a report for an item", async () => {
    const res = await api
      .post("/reports")
      .set("Authorization", `Bearer ${userToken}`)
      .send({
        itemId,
        reason: "fake",
        description: "Seems fake",
      });

    expect(res.status).to.equal(201);
    expect(res.body.report).to.include({ itemId, reason: "fake" });
    reportId = res.body.report.id;
  });

  it("lists only the user's reports", async () => {
    const res = await api
      .get("/reports")
      .set("Authorization", `Bearer ${userToken}`);
    expect(res.status).to.equal(200);
    expect(res.body.reports).to.be.an("array");
    expect(
      res.body.reports.some((r: { id: number }) => r.id === reportId),
    ).to.equal(true);
  });

  it("lets admin list all reports", async () => {
    const res = await api
      .get("/reports")
      .set("Authorization", `Bearer ${adminToken}`);
    expect(res.status).to.equal(200);
    expect(res.body.reports).to.be.an("array");
    expect(
      res.body.reports.some((r: { id: number }) => r.id === reportId),
    ).to.equal(true);
  });

  it("lets owner update their report description", async () => {
    const res = await api
      .put(`/reports/${reportId}`)
      .set("Authorization", `Bearer ${userToken}`)
      .send({ description: "Updated description" });
    expect(res.status).to.equal(200);
    expect(res.body.report).to.include({
      id: reportId,
      description: "Updated description",
    });
  });

  it("lets admin update status and adminNote", async () => {
    const res = await api
      .put(`/reports/${reportId}`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "under_review", adminNote: "Investigating" });
    expect(res.status).to.equal(200);
    expect(res.body.report).to.include({
      id: reportId,
      status: "under_review",
      adminNote: "Investigating",
    });
  });

  it("lets admin delete a report", async () => {
    const res = await api
      .delete(`/reports/${reportId}`)
      .set("Authorization", `Bearer ${adminToken}`);
    expect(res.status).to.equal(200);
    expect(res.body.message).to.equal("Report deleted successfully");
  });

  after(async () => {
    await api
      .delete(`/items/${itemId}`)
      .set("Authorization", `Bearer ${userToken}`);
    await api.delete(`/users/${userId}`);
    await api.delete(`/users/${adminId}`);
  });
});
