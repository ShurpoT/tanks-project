import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
    schema: "./back/src/graphql/schema.ts",
    documents: ["./tech-tree-editor/**/*.graphql"],

    generates: {
        "./back/src/types/__generated__/index.ts": {
            plugins: ["typescript", "typescript-resolvers"],
            config: {
                contextType: "../../context.js#IContext",
                scalars: {
                    ID: "number",
                },
            },
        },

        "./tech-tree-editor/src/graphql/": {
            preset: "near-operation-file",
            presetConfig: {
                extension: ".ts",
                folder: "__generated__",
                baseTypesPath: "__generated__/types.ts",
            },
            plugins: ["typescript", "typescript-operations", "typescript-react-apollo"],
            config: {
                withHooks: true,
                scalars: {
                    ID: "number",
                },
            },
        },
    },
};

export default config;
