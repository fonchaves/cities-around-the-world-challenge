/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable require-jsdoc */
import {logger} from "firebase-functions";
import {
  initializeApp,
  credential,
  firestore,
  ServiceAccount,
} from "firebase-admin";
import * as fs from "fs";

import {parse} from "csv-parse";
import {resolve} from "path";
import * as serviceAccount from "./serviceAccountKey.json";

const BATCH_TRANSACTION_LIMIT = 500;
const CSV_FILE_PATH = resolve(
    __dirname,
    "data",
    "world-cities-light.csv"
);

async function connectToFirestore() {
  initializeApp({
    credential: credential.cert(serviceAccount as ServiceAccount),
  });

  return firestore();
}

async function writeToFirestore(records: any[]) {
  const batchCommits = [];
  let countRecords = 0;

  const FirestoreInstance = await connectToFirestore();

  let batch = FirestoreInstance.batch();

  records.forEach((record) => {
    const docRef = FirestoreInstance.collection("cities").doc(record[3]);
    batch.set(docRef, {
      name: record[0],
      country: record[1],
      subCountry: record[2],
      geoNameId: record[3],
    });
    logger.info(`Adding record ${countRecords + 1}`);

    /**
     * Due a Firestore Spark plan limit, its necessary to send limit
     * batches of 500 transactions each.
     * Ref: https://stackoverflow.com/questions/52165352/how-can-i-update-more-than-500-docs-in-firestore-using-batch
     */
    if ((countRecords + 1) % BATCH_TRANSACTION_LIMIT === 0) {
      logger.info(`Adding new batch ${countRecords + 1}`);
      batchCommits.push(batch);
      batch = FirestoreInstance.batch();
    }
    countRecords += 1;
  });

  batchCommits.push(batch);

  const promises = batchCommits.map((batch) => batch.commit());
  return Promise.all(promises);
}

async function importCsv(csvFileName: string) {
  const records = [];
  const parser = fs
      .createReadStream(csvFileName)
      .pipe(parse({delimiter: ",", from_line: 2}));

  for await (const record of parser) {
    records.push(record);
  }

  try {
    await writeToFirestore(records);
  } catch (e) {
    logger.error(e);
    process.exit(1);
  }
  logger.info("\nImport completed!\n");
}

/**
 * Main function
 */
importCsv(CSV_FILE_PATH).catch((e) => console.error(e));
