const atUri = process.argv[2];

if (!atUri) {
  console.error(
    "Usage: node _scripts/check-standard-document.mjs <at://...>"
  );
  process.exit(1);
}

const match = atUri.match(
  /^at:\/\/([^/]+)\/([^/]+)\/([^/]+)$/
);

if (!match) {
  throw new Error(`Invalid AT URI: ${atUri}`);
}

const [, repo, collection, rkey] = match;

const url =
  "https://atproto.brid.gy/xrpc/com.atproto.repo.getRecord?" +
  new URLSearchParams({
    repo,
    collection,
    rkey
  });

const response = await fetch(url);

if (!response.ok) {
  throw new Error(
    `Request failed (${response.status}): ${await response.text()}`
  );
}

const record = await response.json();

console.log(`URI: ${record.uri}`);
console.log(`CID: ${record.cid}`);
console.log("");
console.log(JSON.stringify(record.value, null, 2));

console.log("");
console.log("Fields:");
for (const key of Object.keys(record.value)) {
  console.log(`- ${key}`);
}
