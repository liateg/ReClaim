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
  const adminEmail = `claim-admin-${uniqueId}@example.com`;

  let ownerId: number;
  let ownerToken: string;
  let claimantId: number;
  let claimantToken: string;
  let adminId: number;
  let adminToken: string;
  let itemId: number;
  let claimId: number;
  let rejectedClaimId: number;

  before(async () => {
    const ownerRes = await api.post("/auth/register").send({
      name: "Claim Owner",
      email: ownerEmail,
      password: "MyTestPass!23",
    });

    expect(ownerRes.status).to.equal(201);
    ownerId = ownerRes.body.user.id;
    ownerToken = ownerRes.body.accessToken;

    const claimantRes = await api.post("/auth/register").send({
      name: "Claimant",
      email: claimantEmail,
      password: "MyTestPass!23",
    });

    expect(claimantRes.status).to.equal(201);
    claimantId = claimantRes.body.user.id;
    claimantToken = claimantRes.body.accessToken;

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
    adminToken = loginRes.body.accessToken;

    const itemRes = await api
      .post("/items")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: `Claim Item ${uniqueId}`,
        description: "Claim test item",
        location: "Storage Room",
        dateFound: "2026-05-21",
        verificationQuestion: "What is the hidden detail?",
        verificationAnswer: "Blue tag",
        status: "available",
      });

    expect(itemRes.status).to.equal(201);
    itemId = itemRes.body.item.id;
  });

  it("creates a claim for the authenticated user", async () => {
    const res = await api
      .post("/claims")
      .set("Authorization", `Bearer ${claimantToken}`)
      .send({
        itemId,
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

  it("creates a second claim for admin review", async () => {
    const res = await api
      .post("/claims")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        itemId,
        answerAttempt: "Wrong answer",
      });

    expect(res.status).to.equal(201);
    expect(res.body.claim).to.include({
      itemId,
      claimantId: ownerId,
      status: "pending",
    });
    rejectedClaimId = res.body.claim.id;
  });

  it("lists only the authenticated user's claims", async () => {
    const res = await api
      .get("/claims")
      .set("Authorization", `Bearer ${claimantToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.claims).to.be.an("array");
    expect(
      res.body.claims.some((claim: { id: number }) => claim.id === claimId),
    ).to.equal(true);
    expect(
      res.body.claims.some((claim: { id: number }) => claim.id === rejectedClaimId),
    ).to.equal(false);
  });

  it("lets admin list all claims", async () => {
    const res = await api
      .get("/claims")
      .set("Authorization", `Bearer ${adminToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.claims).to.be.an("array");
    expect(
      res.body.claims.some((claim: { id: number }) => claim.id === claimId),
    ).to.equal(true);
    expect(
      res.body.claims.some((claim: { id: number }) => claim.id === rejectedClaimId),
    ).to.equal(true);
  });

  it("gets a claim by id for the owner", async () => {
    const res = await api
      .get(`/claims/${claimId}`)
      .set("Authorization", `Bearer ${claimantToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.claim).to.include({ id: claimId, itemId, claimantId });
  });

  it("blocks access to another user's claim", async () => {
    const res = await api
      .get(`/claims/${rejectedClaimId}`)
      .set("Authorization", `Bearer ${claimantToken}`);

    expect(res.status).to.equal(403);
  });

  it("updates a claim the owner controls", async () => {
    const res = await api
      .put(`/claims/${claimId}`)
      .set("Authorization", `Bearer ${claimantToken}`)
      .send({
        status: "withdrawn",
        answerAttempt: "Blue tag",
      });

    expect(res.status).to.equal(200);
    expect(res.body.claim).to.include({
      id: claimId,
      status: "withdrawn",
    });
  });

  it("approves a matching claim as admin", async () => {
    const res = await api
      .patch(`/claims/${claimId}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
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

  it("rejects a mismatched claim as admin", async () => {
    const res = await api
      .patch(`/claims/${rejectedClaimId}/review`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        reviewNote: "Answer did not match the item record",
      });

    expect(res.status).to.equal(200);
    expect(res.body.claim).to.include({
      id: rejectedClaimId,
      status: "rejected",
      reviewNote: "Answer did not match the item record",
    });
  });

  it("deletes a claim", async () => {
    const res = await api
      .delete(`/claims/${claimId}`)
      .set("Authorization", `Bearer ${claimantToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.message).to.equal("Claim deleted successfully");
  });

  after(async () => {
    await api.delete(`/claims/${rejectedClaimId}`).set("Authorization", `Bearer ${adminToken}`);
    await api.delete(`/items/${itemId}`).set("Authorization", `Bearer ${ownerToken}`);
    await api.delete(`/users/${claimantId}`);
    await api.delete(`/users/${ownerId}`);
    await api.delete(`/users/${adminId}`);
  });
});
