import express, { Request, Response } from "express";
import cors from "cors";
import * as dotenv from "dotenv";
import { JWT } from "google-auth-library";
import * as admin from "firebase-admin";

const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(cors());

dotenv.config();

// Firebase Admin SDK 초기화
const serviceAccount = require("../service-account-file.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Google OAuth 2.0 범위 설정
const SCOPES = ["https://www.googleapis.com/auth/cloud-platform"];

// Google OAuth 2.0 토큰 생성 함수
function getAccessToken() {
  return new Promise<string>((resolve, reject) => {
    const key = require("../service-account-file.json");

    const clientEmail = key.client_email;
    const privateKey = key.private_key;

    if (!clientEmail || !privateKey) {
      return reject(
        new Error("Service account file is missing required fields.")
      );
    }

    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: SCOPES,
    });

    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      if (!tokens || !tokens.access_token) {
        reject(new Error("No access token returned"));
        return;
      }
      resolve(tokens.access_token);
    });
  });
}

app.listen(process.env.PORT || 8080, () => {
  console.log("서버연결");
});

app.get("/", (req: Request, res: Response) => {
  return res.status(200).json("Ride This 서버 연결!");
});

app.get("/token", async (req, res) => {
  try {
    // google-auth-library를 사용하여 액세스 토큰 생성
    const token = await getAccessToken();
    res.status(200).json({ accessToken: token });
  } catch (error) {
    console.error("Error generating access token:", error);
    res.status(500).json({ error: "Failed to generate access token" });
  }
});
