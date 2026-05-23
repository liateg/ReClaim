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

interface Notification {
  id: number;
  userId: number;
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
}

class MemoryStore {
  private items: Item[] = [
    {
      id: 1,
      title: "Silver iPhone 13 Pro",
      description: "Found near the library cafeteria. Has a clear case with a distinctive sticker on the back.",
      category: "Electronics",
      location: "Library Cafeteria",
      dateFound: new Date().toISOString(),
      imageUrl: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=1000",
      verificationQuestion: "What is the flower on the wallpaper?",
      verificationAnswer: "Sunflower",
      hiddenDetails: "Slight scratch on the bottom left corner.",
      status: "available",
      postedBy: 999,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: 2,
      title: "Black Leather Wallet",
      description: "Found in the parking lot. Contains no cash but has multiple student IDs and a library card.",
      category: "Personal Items",
      location: "Main Parking Lot",
      dateFound: new Date().toISOString(),
      imageUrl: "https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=1000",
      verificationQuestion: "What is the initial on the ID card?",
      verificationAnswer: "J.D.",
      hiddenDetails: "There is a lucky coin in the hidden compartment.",
      status: "available",
      postedBy: 888,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ];

  private claims: Claim[] = [
    {
      id: 1,
      itemId: 1,
      claimantId: 777,
      answerAttempt: "A daisy",
      status: "pending",
      reviewNote: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }
  ];

  private notifications: Notification[] = [];

  private itemIdCounter = 3;
  private claimIdCounter = 2;
  private notificationIdCounter = 1;

  // Notifications
  getNotificationsByUser(userId: number) {
    return this.notifications.filter(n => n.userId === userId);
  }
  createNotification(userId: number, title: string, message: string) {
    const newNotif: Notification = {
      id: this.notificationIdCounter++,
      userId,
      title,
      message,
      read: false,
      createdAt: new Date().toISOString(),
    };
    this.notifications.push(newNotif);
    return newNotif;
  }
  markNotificationRead(id: number) {
    const notif = this.notifications.find(n => n.id === id);
    if (notif) notif.read = true;
  }

  // Items
  getItems() { return this.items; }
  getItemById(id: number) { return this.items.find(i => i.id === id); }
  createItem(itemData: Partial<Item>) {
    const newItem: Item = {
      id: this.itemIdCounter++,
      title: itemData.title!,
      description: itemData.description!,
      category: itemData.category ?? "Other",
      location: itemData.location!,
      dateFound: itemData.dateFound!,
      imageUrl: itemData.imageUrl ?? null,
      verificationQuestion: itemData.verificationQuestion!,
      verificationAnswer: itemData.verificationAnswer!,
      hiddenDetails: itemData.hiddenDetails ?? null,
      status: itemData.status ?? "available",
      postedBy: itemData.postedBy!,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.items.push(newItem);
    return newItem;
  }
  updateItem(id: number, updates: Partial<Item>) {
    const index = this.items.findIndex(i => i.id === id);
    if (index === -1) return null;
    this.items[index] = { ...this.items[index], ...updates, updatedAt: new Date().toISOString() } as Item;
    return this.items[index];
  }
  deleteItem(id: number) {
    const index = this.items.findIndex(i => i.id === id);
    if (index === -1) return false;
    this.items.splice(index, 1);
    return true;
  }

  // Claims
  getClaims() { return this.claims; }
  getClaimsByUser(userId: number) { return this.claims.filter(c => c.claimantId === userId); }
  getClaimById(id: number) { return this.claims.find(c => c.id === id); }
  createClaim(claimData: Partial<Claim>) {
    const newClaim: Claim = {
      id: this.claimIdCounter++,
      itemId: claimData.itemId!,
      claimantId: claimData.claimantId!,
      answerAttempt: claimData.answerAttempt!,
      status: claimData.status ?? "pending",
      reviewNote: claimData.reviewNote ?? null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.claims.push(newClaim);
    return newClaim;
  }
  updateClaim(id: number, updates: Partial<Claim>) {
    const index = this.claims.findIndex(c => c.id === id);
    if (index === -1) return null;
    this.claims[index] = { ...this.claims[index], ...updates, updatedAt: new Date().toISOString() } as Claim;
    return this.claims[index];
  }
  deleteClaim(id: number) {
    const index = this.claims.findIndex(c => c.id === id);
    if (index === -1) return false;
    this.claims.splice(index, 1);
    return true;
  }
}

export const memoryStore = new MemoryStore();
