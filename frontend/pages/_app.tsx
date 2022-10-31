import type { AppProps } from "next/app";
import Head from "next/head";

import "../styles/globals.css";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Head>
        <title>Alcatraz</title>
        <meta
          name="description"
          content="A Casino like DApp built on Sei, BlazinglyFast™, Simple, and Secure."
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Component {...pageProps} />
    </>
  );
}

export default MyApp;
