/* eslint-disable @typescript-eslint/no-unused-vars */
import * as logger from "firebase-functions/logger";
import {onCall} from "firebase-functions/v2/https";

export const recordWakeSession = onCall(async (request) => {
  logger.info("recordWakeSession invoked", {uid: request.auth?.uid});
  return {ok: true};
});

export const evaluatePenaltyEvent = onCall(async (request) => {
  logger.info("evaluatePenaltyEvent invoked", {uid: request.auth?.uid});
  return {ok: true};
});

export const createLedgerEntry = onCall(async (request) => {
  logger.info("createLedgerEntry invoked", {uid: request.auth?.uid});
  return {ok: true};
});

export const syncDeviceAlarmState = onCall(async (request) => {
  logger.info("syncDeviceAlarmState invoked", {uid: request.auth?.uid});
  return {ok: true};
});
