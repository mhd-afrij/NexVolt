const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const projectId = 'nexvolt-data';
const dbPath = path.join(__dirname, 'data', 'db.json');
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

function initFirestore() {
  let credential;

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    credential = admin.credential.applicationDefault();
    console.log('Using GOOGLE_APPLICATION_CREDENTIALS for Firebase Admin authentication.');
  } else if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    credential = admin.credential.cert(serviceAccount);
    console.log('Using serviceAccountKey.json for Firebase Admin authentication.');
  } else {
    throw new Error(
      'No Firebase Admin credentials found. Set GOOGLE_APPLICATION_CREDENTIALS or create backend/serviceAccountKey.json.'
    );
  }

  admin.initializeApp({
    credential,
    projectId,
  });

  return admin.firestore();
}

function loadSeedData() {
  const raw = fs.readFileSync(dbPath, 'utf-8');
  return JSON.parse(raw);
}

async function deleteCollection(db, collectionName) {
  const snapshot = await db.collection(collectionName).get();
  if (snapshot.empty) {
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  console.log(`Cleared collection: ${collectionName}`);
}

async function seedCollection(db, collectionName, items) {
  const batch = db.batch();
  items.forEach((item) => {
    const docRef = db.collection(collectionName).doc(item.id);
    batch.set(docRef, item);
  });
  await batch.commit();
  console.log(`Seeded ${items.length} documents into ${collectionName}`);
}

async function run() {
  const db = initFirestore();
  const seedData = loadSeedData();

  const collections = [
    { name: 'vehicles', items: seedData.vehicles || [] },
    { name: 'timelineEvents', items: seedData.timelineEvents || [] },
    { name: 'distanceLogs', items: seedData.distanceLogs || [] },
    { name: 'maintenance', items: seedData.maintenance || [] },
  ];

  for (const collection of collections) {
    await deleteCollection(db, collection.name);
    if (collection.items.length > 0) {
      await seedCollection(db, collection.name, collection.items);
    }
  }

  console.log('Firestore seeding complete.');
  process.exit(0);
}

run().catch((error) => {
  console.error('Firestore seeding failed:', error);
  process.exit(1);
});
