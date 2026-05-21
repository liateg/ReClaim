import dotenv from "dotenv";
import request from "supertest";
import { expect } from "chai";
import App from "../src/app.js";

dotenv.config();

describe("Items API", () => {
  const api = request(App);
  const uniqueId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const ownerEmail = `item-owner-${uniqueId}@example.com`;
  const adminEmail = `item-admin-${uniqueId}@example.com`;
  const otherEmail = `item-other-${uniqueId}@example.com`;

  let ownerId: number;
  let ownerToken: string;
  let adminId: number;
  let adminToken: string;
  let otherId: number;
  let otherToken: string;
  let itemId: number;

  before(async () => {
    const ownerRes = await api.post("/auth/register").send({
      name: "Item Owner",
      email: ownerEmail,
      password: "MyTestPass!23",
    });

    expect(ownerRes.status).to.equal(201);
    ownerId = ownerRes.body.user.id;
    ownerToken = ownerRes.body.accessToken;

    const adminRes = await api.post("/users").send({
      fullName: "Item Admin",
      email: adminEmail,
      password: "MyTestPass!23",
      role: "admin",
    });

    expect(adminRes.status).to.equal(201);
    adminId = adminRes.body.user.id;

    const adminLogin = await api.post("/auth/login").send({
      email: adminEmail,
      password: "MyTestPass!23",
    });

    expect(adminLogin.status).to.equal(200);
    adminToken = adminLogin.body.accessToken;

    const otherRes = await api.post("/auth/register").send({
      name: "Item Other",
      email: otherEmail,
      password: "MyTestPass!23",
    });

    expect(otherRes.status).to.equal(201);
    otherId = otherRes.body.user.id;
    otherToken = otherRes.body.accessToken;
  });

  it("creates an item", async () => {
    const res = await api.post("/items").set("Authorization", `Bearer ${ownerToken}`).send({
      title: `Lost Wallet ${uniqueId}`,
      description: "Black leather wallet",
      location: "Main Hall",
      dateFound: "2026-05-21",
      verificationQuestion: "What is inside?",
      verificationAnswer: "Two cards",
      status: "available",
    });

    expect(res.status).to.equal(201);
    expect(res.body.item).to.include({
      title: `Lost Wallet ${uniqueId}`,
      status: "available",
    });
    itemId = res.body.item.id;
  });

  it("lists items", async () => {
    const res = await api.get("/items").set("Authorization", `Bearer ${ownerToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.items).to.be.an("array");
    expect(res.body.items[0]).to.not.have.property("verificationAnswer");
    expect(
      res.body.items.some((item: { id: number }) => item.id === itemId),
    ).to.equal(true);
  });

  it("gets an item by id", async () => {
    const res = await api.get(`/items/${itemId}`).set("Authorization", `Bearer ${ownerToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.item).to.include({ id: itemId, postedBy: ownerId });
    expect(res.body.item).to.not.have.property("verificationAnswer");
  });

  it("gets a full item detail for admin", async () => {
    const res = await api
      .get(`/items/${itemId}`)
      .set("Authorization", `Bearer ${adminToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.item).to.have.property("verificationAnswer", "Two cards");
  });

  it("updates an item", async () => {
    const res = await api.put(`/items/${itemId}`).set("Authorization", `Bearer ${ownerToken}`).send({
      title: `Found Wallet ${uniqueId}`,
      status: "claimed",
      description: "Black leather wallet with updated note",
      location: "Reception",
      dateFound: "2026-05-22",
      verificationQuestion: "What color is the wallet?",
      verificationAnswer: "Black",
    });

    expect(res.status).to.equal(200);
    expect(res.body.item).to.include({
      id: itemId,
      title: `Found Wallet ${uniqueId}`,
      status: "claimed",
    });
  });

  it("blocks another user from updating the item", async () => {
    const res = await api.put(`/items/${itemId}`).set("Authorization", `Bearer ${otherToken}`).send({
      title: "Should fail",
    });

    expect(res.status).to.equal(403);
  });

  it("lets admin view the full item list", async () => {
    const res = await api.get("/items/admin").set("Authorization", `Bearer ${adminToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.items[0]).to.have.property("verificationAnswer");
  });

  it("deletes an item", async () => {
    const res = await api.delete(`/items/${itemId}`).set("Authorization", `Bearer ${ownerToken}`);

    expect(res.status).to.equal(200);
    expect(res.body.message).to.equal("Item deleted successfully");
  });

  after(async () => {
    await api.delete(`/users/${ownerId}`);
    await api.delete(`/users/${adminId}`);
    await api.delete(`/users/${otherId}`);
  });
});
