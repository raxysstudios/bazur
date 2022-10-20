/* eslint-disable require-jsdoc */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";

function getLangDoc(entry: functions.firestore.QueryDocumentSnapshot):
  firestore.DocumentReference<firestore.DocumentData> {
  const lang = entry.get("language");
  return firestore().doc(`languages/${lang}`);
}

export const countEntry = functions
    .region("europe-central2")
    .firestore.document("dictionary/{entryID}")
    .onCreate(async (entry) => {
      await getLangDoc(entry).update({
        dictionary: firestore.FieldValue.increment(1),
      });
    });

export const discountEntry = functions
    .region("europe-central2")
    .firestore.document("dictionary/{entryID}")
    .onDelete(async (entry) => {
      await getLangDoc(entry).update({
        dictionary: firestore.FieldValue.increment(-1),
      });
    });
