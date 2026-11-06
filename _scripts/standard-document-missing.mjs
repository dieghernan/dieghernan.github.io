
const did = "did:plc:frgeqa77h66m6s4a67pdotgl";
const collection = "site.standard.document";
const api = "https://atproto.brid.gy/xrpc/com.atproto.repo.listRecords";

async function getRecords() {
  const records = [];
  let cursor;

  do {
    const url = new URL(api);
    url.searchParams.set("repo", did);
    url.searchParams.set("collection", collection);
    url.searchParams.set("limit", "100");
    if (cursor) url.searchParams.set("cursor", cursor);

    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`AT Protocol: HTTP ${response.status}`);
    }

    const data = await response.json();
    records.push(...(data.records ?? []));
    cursor = data.cursor;
  } while (cursor);

  return records;
}

async function hasLink(url, uri) {
  const response = await fetch(url);

if (!response.ok) {
  throw new Error(
    `AT Protocol: HTTP ${response.status}\n${await response.text()}`
  );
}

  const html = await response.text();
  const head = html.match(/<head\b[^>]*>([\s\S]*?)<\/head\s*>/i)?.[1];

  if (!head) return false;

  const links = head.match(/<link\b[^>]*>/gi) ?? [];

  return links.some((tag) => {
    const rel = tag.match(/\brel\s*=\s*["']([^"']+)["']/i)?.[1];
    const href = tag.match(/\bhref\s*=\s*["']([^"']+)["']/i)?.[1];

    return rel?.split(/\s+/).includes(collection) && href === uri;
  });
}

const records = await getRecords();
const missing = [];

for (const { uri, value } of records) {
const url = value.site && value.path
  ? new URL(value.path, value.site).href
  : null;

  if (!url) {
    missing.push({ url: "(sin URL)", uri, status: "Sin URL" });
    continue;
  }

  try {
    if (!(await hasLink(url, uri))) {
      missing.push({ url, uri, status: "Falta link" });
    }
  } catch (error) {
    missing.push({ url, uri, status: error.message });
  }
}

if (missing.length) {
  console.table(missing);
} else {
  console.log("Todos los documentos tienen su link en el head.");
}

console.log(`Comprobados: ${records.length}. Incidencias: ${missing.length}.`);
