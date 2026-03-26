import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Creates a Setu AA consent request for the given phone number.
 * Returns the redirect URL to show in a WebView.
 *
 * In production, replace the mock URL with a real Setu API call using
 * your FIU client credentials stored in Firebase Secret Manager.
 */
export const createConsentRequest = functions
  .region("asia-south1")
  .https.onCall(async (data: { phoneNumber: string }) => {
    const { phoneNumber } = data;

    if (!phoneNumber || !phoneNumber.startsWith("+91")) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "phoneNumber must be a valid Indian mobile number starting with +91"
      );
    }

    // TODO: Replace with real Setu AA API call
    // const setuResponse = await setuClient.createConsent({ vua: `${phoneNumber}@setu` });
    // return { redirectUrl: setuResponse.url };

    const mockConsentId = `consent-${Date.now()}`;
    return {
      redirectUrl: `https://setu.co/aa-sdk/consent?id=${mockConsentId}&phone=${encodeURIComponent(phoneNumber)}`,
    };
  });
