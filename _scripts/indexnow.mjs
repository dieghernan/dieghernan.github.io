const HOST = "dieghernan.github.io";
const KEY = "acfe7ec1a7da445f9880d1e1420ca8db";
const ENDPOINT = "https://api.indexnow.org/indexnow";

const paths = process.argv.slice(2);

function pathToUrl(path) {
  // Normalise separators
  path = path.replaceAll("\\", "/");

  // We only want published HTML pages
  if (!path.endsWith(".html")) {
    return null;
  }

  // Jekyll's foo/index.html -> /foo/
  if (path === "index.html") {
    path = "";
  } else if (path.endsWith("/index.html")) {
    path = path.slice(0, -10);
  }

  return `https://${HOST}/${path}`;
}

const urls = [...new Set(paths.map(pathToUrl).filter(Boolean))];

if (urls.length === 0) {
  console.log("IndexNow: no changed HTML URLs to submit.");
  process.exit(0);
}

console.log(`IndexNow: submitting ${urls.length} URL(s):`);

for (const url of urls) {
  console.log(`  ${url}`);
}

// IndexNow accepts up to 10,000 URLs per request.
for (let i = 0; i < urls.length; i += 10000) {
  const urlList = urls.slice(i, i + 10000);

  const response = await fetch(ENDPOINT, {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
    },
    body: JSON.stringify({
      host: HOST,
      key: KEY,
      keyLocation: `https://${HOST}/${KEY}.txt`,
      urlList,
    }),
  });

  if (response.status !== 200 && response.status !== 202) {
    const body = await response.text();

    throw new Error(
      `IndexNow request failed (${response.status}): ${body}`
    );
  }

  console.log(
    `IndexNow: ${response.status} -- submitted ${urlList.length} URL(s).`
  );
}
