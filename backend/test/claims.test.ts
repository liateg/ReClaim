import dotenv from "dotenv";
import request from "supertest";
import { expect } from "chai";
import App from "../src/app.js";

dotenv.config();

describe("Claims API", () => {
  const api = request(App);
  const uniqueId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const ownerEmail = `claim-owner-${uniqueId}@example.com`;
  const claimantEmail = `claimant-${uniqueId}@example.com`;

  let ownerId: number;
  let claimantId: number;
  let adminId: number;
  let itemId: number;
  let claimId: number;
  let adminAccessToken: string;

  before(async () => {
    const ownerRes = await api.post("/users").send({
      fullName: "Claim Owner",
      email: ownerEmail,
      password: "MyTestPass!23",
    });

    ownerId = ownerRes.body.user.id;

    const claimantRes = await api.post("/users").send({
      fullName: "Claimant",
      email: claimantEmail,
      password: "MyTestPass!23",
    });

    claimantId = claimantRes.body.user.id;

    const adminEmail = `claim-admin-${uniqueId}@example.com`;

    const adminRes = await api.post("/users").send({
      fullName: "Claim Admin",
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
    adminAccessToken = loginRes.body.accessToken;

    const itemRes = await api.post("/items").send({
      title: `Claim Item ${uniqueId}`,
      description: "Claim test item",
      location: "Storage Room",
      dateFound: "2026-05-21",
      verificationQuestion: "What is the hidden detail?",
      verificationAnswer: "Blue tag",
      postedBy: ownerId,
      status: "available",
    });

    itemId = itemRes.body.item.id;
  });

  it("creates a claim", async () => {
    const res = await api.post("/claims").send({
      itemId,
      claimantId,
      answerAttempt: "Blue tag",
      status: "pending",
    });

    expect(res.status).to.equal(201);
    expect(res.body.claim).to.include({
      itemId,
      claimantId,
      status: "pending",
    });
    claimId = res.body.claim.id;
  });

  it("lists claims", async () => {
    const res = await api.get("/claims");

    expect(res.status).to.equal(200);
    expect(res.body.claims).to.be.an("array");
    expect(
      res.body.claims.some((claim: { id: number }) => claim.id === claimId),
    ).to.equal(true);
  });

  it("gets a claim by id", async () => {
    const res = await api.get(`/claims/${claimId}`);

    expect(res.status).to.equal(200);
    expect(res.body.claim).to.include({ id: claimId, itemId, claimantId });
  });

  it("updates a claim", async () => {
    const res = await api.put(`/claims/${claimId}`).send({
      status: "withdrawn",
      reviewNote: "Needs admin review",
      answerAttempt: "Blue tag",
      itemId,
      claimantId,
    });

    expect(res.status).to.equal(200);
    expect(res.body.claim).to.include({
      id: claimId,
      status: "withdrawn",
      reviewNote: "Needs admin review",
    });
  });

  it("approves a claim as admin", async () => {
    const res = await api
      .patch(`/claims/${claimId}/approve`)
      .set("Authorization", `Bearer ${adminAccessToken}`)
      .send({
        reviewNote: "Verified and approved",
      });

    expect(res.status).to.equal(200);
    expect(res.body.claim).to.include({
      id: claimId,
      status: "approved",
      reviewNote: "Verified and approved",
    });
  });

  it("deletes a claim", async () => {
    const res = await api.delete(`/claims/${claimId}`);

    expect(res.status).to.equal(200);
    expect(res.body.message).to.equal("Claim deleted successfully");
  });

  after(async () => {
    await api.delete(`/items/${itemId}`);
    await api.delete(`/users/${claimantId}`);
    await api.delete(`/users/${ownerId}`);
    await api.delete(`/users/${adminId}`);
  });
});
