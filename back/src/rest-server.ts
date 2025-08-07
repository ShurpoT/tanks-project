import express from "express";
import cookieParser from "cookie-parser";
import cors, { type CorsOptions } from "cors";
import path from "path";
import { fileURLToPath } from "url";

const __filename: string = fileURLToPath(import.meta.url);
const __dirname: string = path.dirname(__filename);

export const app = express();

const port: number = 3007;
const corsSettings: CorsOptions = {
    origin: "*",
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    credentials: true,
    allowedHeaders: ["Content-Type", "Authorization"],
};

app.use(express.json());
app.use(cookieParser());
app.use(cors(corsSettings));

// app.use("/paht", express.static(path.join(__dirname, "..", "public", "models")));
// http://localhost:3007/images/vehicles/small/ussr-R08_BT-2.png
app.use("/images", express.static(path.join(__dirname, "..", "public", "images")));
app.use("/videos", express.static(path.join(__dirname, "..", "public", "videos")));
app.use("/models", express.static(path.join(__dirname, "..", "public", "models")));

app.listen(port, () => {
    console.log(`\n\nExpress server ready: \x1b[38;5;208mhttp://localhost:${port}/\x1b[0m\x1b[39m`);
});
