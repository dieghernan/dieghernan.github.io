const DID = "did:plc:frgeqa77h66m6s4a67pdotgl";
const COLLECTION = "site.standard.publication";
const RKEY = "3mz4rebd4okx2";
const PDS = "https://atproto.brid.gy";

const url =
  `${PDS}/xrpc/com.atproto.repo.getRecord?` +
  new URLSearchParams({
    repo: DID,
    collection: COLLECTION,
    rkey: RKEY
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
console.log("Name:");
console.log(record.value.name);

console.log("");
console.log("Unicode code points:");
console.log(
  [...record.value.name]
    .map(char =>
      `${char}  U+${char.codePointAt(0).toString(16).toUpperCase().padStart(4, "0")}`
    )
    .join("\n")
);