import { defineConfig } from "tsup";

export default defineConfig({
    entry: ["src/graphql-server.ts", "src/rest-server.ts"],
    format: ["esm"],
    target: "esnext",
    splitting: true,
});
