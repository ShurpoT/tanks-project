import { defineConfig } from "tsup";

export default defineConfig({
    entry: ["src/index.ts", "src/server.ts"],
    format: ["esm"],
    target: "esnext",
    splitting: true,
});
