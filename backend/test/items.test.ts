import dotenv from "dotenv";
import request from "supertest";
import { expect } from "chai";
import App from "../src/app.js";

dotenv.config();

describe("Items API", () => {
  const api = request(App);
  const uniqueId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const ownerEmail = `item-owner-${uniqueId}@example.com`;

  let ownerId: number;
  let itemId: number;

  before(async () => {
    const userRes = await api.post("/users").send({
      fullName: "Item Owner",
      email: ownerEmail,
      password: "MyTestPass!23",
    });

    ownerId = userRes.body.user.id;
  });

  it("creates an item", async () => {
    const res = await api.post("/items").send({
      title: `Lost Wallet ${uniqueId}`,
      description: "Black leather wallet",
      location: "Main Hall",
      dateFound: "2026-05-21",
      verificationQuestion: "What is inside?",
      verificationAnswer: "Two cards",
      postedBy: ownerId,
      status: "available",
    });

    expect(res.status).to.equal(201);
    expect(res.body.item).to.include({ title: `Lost Wallet ${uniqueId}`, status: "available", postedBy: ownerId });
    itemId = res.body.item.id;
  });

  it("lists items", async () => {
    const res = await api.get("/items");

    expect(res.status).to.equal(200);
    expect(res.body.items).to.be.an("array");
    expect(res.body.items.some((item: { id: number }) => item.id === itemId)).to.equal(true);
  });

  it("gets an item by id", async () => {
    const res = await api.get(`/items/${itemId}`);

    expect(res.status).to.equal(200);
    expect(res.body.item).to.include({ id: itemId, postedBy: ownerId });
  });

  it("updates an item", async () => {
    const res = await api.put(`/items/${itemId}`).send({
      title: `Found Wallet ${uniqueId}`,
      status: "claimed",
      postedBy: ownerId,
      description: "Black leather wallet with updated note",
      location: "Reception",
      dateFound: "2026-05-22",
      verificationQuestion: "What color is the wallet?",
      verificationAnswer: "Black",
    });

    expect(res.status).to.equal(200);
    expect(res.body.item).to.include({ id: itemId, title: `Found Wallet ${uniqueId}`, status: "claimed" });
  });

  it("deletes an item", async () => {
    const res = await api.delete(`/items/${itemId}`);

    expect(res.status).to.equal(200);
    expect(res.body.message).to.equal("Item deleted successfully");
  });

  after(async () => {
    await api.delete(`/users/${ownerId}`);
  });
});