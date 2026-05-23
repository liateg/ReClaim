import { type Request, type Response } from "express";
import { type AuthTokenPayload } from "../../types/auth.js";
import { memoryStore } from "../../utils/memory-store.js";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const allowedStatuses = new Set([
  "pending",
  "approved",
  "rejected",
  "withdrawn",
]);

const getAuth = (req: Request) => (req as AuthedRequest).auth;

const normalizeAnswer = (value: unknown) =>
  typeof value === "string" ? value.trim().toLowerCase() : "";

export const createClaim = async (req: Request, res: Response) => {
  const auth = getAuth(req);
  const { itemId, answerAttempt, status = "pending" } = req.body;

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  if (!itemId || !answerAttempt) {
    return res.status(400).json({ message: "Missing required claim fields" });
  }

  if (!allowedStatuses.has(status)) {
    return res.status(400).json({ message: "Invalid claim status" });
  }

  const existingClaims = memoryStore.getClaimsByUser(auth.id);
  const alreadyClaimed = existingClaims.find(c => c.itemId === Number(itemId) && c.status !== 'withdrawn');
  
  if (alreadyClaimed) {
    return res.status(400).json({ message: "You have already submitted a claim for this item" });
  }

  const newClaim = memoryStore.createClaim({
    itemId: Number(itemId),
    claimantId: auth.id,
    answerAttempt,
    status: status as any,
  });

  return res.status(201).json({
    message: "Claim created successfully",
    claim: newClaim,
  });
};

export const getClaims = async (req: Request, res: Response) => {
  const auth = getAuth(req);
  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  console.log(`DEBUG: GET /claims requested by user ${auth.id} (role: ${auth.role})`);
  const claims = auth.role === "admin"
    ? memoryStore.getClaims()
    : memoryStore.getClaimsByUser(auth.id);
    
  console.log(`DEBUG: Found ${claims.length} claims for user ${auth.id}`);

  // Enrich each claim with item data so the frontend can display title, image etc.
  const enriched = claims.map(claim => {
    const item = memoryStore.getItemById(claim.itemId);
    return {
      ...claim,
      title: item?.title ?? `Claim #${claim.id}`,
      description: item?.description ?? '',
      category: item?.category ?? 'Other',
      location: item?.location ?? 'Unknown',
      imageUrl: item?.imageUrl ?? null,
    };
  });

  return res.status(200).json({ claims: enriched });
};

export const getClaimById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const claim = memoryStore.getClaimById(Number(id));
  if (!claim) {
    return res.status(404).json({ message: "Claim not found" });
  }

  if (auth.role !== "admin" && claim.claimantId !== auth.id) {
    return res.status(403).json({ message: "Access denied" });
  }

  return res.status(200).json({ claim });
};

export const updateClaim = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const claim = memoryStore.getClaimById(Number(id));
  if (!claim) {
    return res.status(404).json({ message: "Claim not found" });
  }

  if (auth.role !== "admin" && claim.claimantId !== auth.id) {
    return res.status(403).json({ message: "Access denied" });
  }

  const updatedClaim = memoryStore.updateClaim(Number(id), req.body);
  return res.status(200).json({
    message: "Claim updated successfully",
    claim: updatedClaim,
  });
};

export const approveClaim = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { reviewNote, status } = req.body;
  const auth = getAuth(req);

  if (!auth || auth.role !== 'admin') {
    return res.status(403).json({ message: "Admin access required" });
  }

  const claim = memoryStore.getClaimById(Number(id));
  if (!claim) {
    return res.status(404).json({ message: "Claim not found" });
  }

  const item = memoryStore.getItemById(claim.itemId);
  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  let finalStatus: "approved" | "rejected";
  let matched = false;

  if (status && (status === "approved" || status === "rejected")) {
    finalStatus = status;
    matched = status === "approved";
  } else {
    matched = normalizeAnswer(claim.answerAttempt) === normalizeAnswer(item.verificationAnswer);
    finalStatus = matched ? "approved" : "rejected";
  }
  
  const finalReviewNote = reviewNote ?? (finalStatus === "approved" ? "Approved" : "Rejected");

  const updatedClaim = memoryStore.updateClaim(Number(id), {
    status: finalStatus,
    reviewNote: finalReviewNote,
  });

  // Notify the user
  memoryStore.createNotification(
    claim.claimantId,
    finalStatus === "approved" ? "Claim Approved! 🎉" : "Claim Rejected ❌",
    `Your claim for the item "${item.title}" has been ${finalStatus}. Note: ${finalReviewNote}`
  );

  return res.status(200).json({
    message: finalStatus === "approved" ? "Claim approved" : "Claim rejected",
    claim: updatedClaim,
  });
};

export const deleteClaim = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  console.log(`DEBUG: DELETE request received for claim ID: ${id}`);
  const allClaims = memoryStore.getClaims();
  console.log(`DEBUG: Current claims in store: ${JSON.stringify(allClaims.map(c => c.id))}`);

  const claim = memoryStore.getClaimById(Number(id));
  if (!claim) {
    console.log(`DEBUG: Claim with ID ${id} not found in store.`);
    return res.status(404).json({ message: "Claim not found" });
  }

  if (auth.role !== "admin" && claim.claimantId !== auth.id) {
    console.log(`DEBUG: Access denied for claim ${id}. Claimant: ${claim.claimantId}, Requester: ${auth.id}`);
    return res.status(403).json({ message: "Access denied" });
  }

  const success = memoryStore.deleteClaim(Number(id));
  if (!success) {
    console.log(`DEBUG: memoryStore.deleteClaim failed for ID ${id}.`);
    return res.status(404).json({ message: `Claim ${id} not found during deletion` });
  }
  
  console.log(`DEBUG: Claim ${id} deleted successfully.`);
  return res.status(200).json({ message: "Claim deleted successfully" });
};
