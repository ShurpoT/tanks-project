import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";

import { typeDefs, resolvers } from "./graphql";
import { type IContext, context } from "~context";

const apolloServer = new ApolloServer<IContext>({
    typeDefs,
    resolvers,
});

const { url } = await startStandaloneServer(apolloServer, {
    context: async () => context,
});

console.log(`Apollo server ready:  \x1b[38;5;201m${url}\x1b[0m\x1b[39m`);
