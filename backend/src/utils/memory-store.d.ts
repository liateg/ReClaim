interface Item {
    id: number;
    title: string;
    description: string;
    category: string;
    location: string;
    dateFound: string;
    imageUrl: string | null;
    verificationQuestion: string;
    verificationAnswer: string;
    hiddenDetails: string | null;
    status: "available" | "claimed" | "resolved";
    postedBy: number;
    createdAt: string;
    updatedAt: string;
}
interface Claim {
    id: number;
    itemId: number;
    claimantId: number;
    answerAttempt: string;
    status: "pending" | "approved" | "rejected" | "withdrawn";
    reviewNote: string | null;
    createdAt: string;
    updatedAt: string;
}
declare class MemoryStore {
    private items;
    private claims;
    private itemIdCounter;
    private claimIdCounter;
    getItems(): Item[];
    getItemById(id: number): Item | undefined;
    createItem(itemData: Partial<Item>): Item;
    updateItem(id: number, updates: Partial<Item>): Item | null;
    deleteItem(id: number): boolean;
    getClaims(): Claim[];
    getClaimsByUser(userId: number): Claim[];
    getClaimById(id: number): Claim | undefined;
    createClaim(claimData: Partial<Claim>): Claim;
    updateClaim(id: number, updates: Partial<Claim>): Claim | null;
    deleteClaim(id: number): boolean;
}
export declare const memoryStore: MemoryStore;
export {};
//# sourceMappingURL=memory-store.d.ts.map