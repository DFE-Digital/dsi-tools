const http = require("http");
const https = require("https");
const url = require("url");

// Maps request to first matching mapping.
const pathMappings = [
  {
    pattern: /^\/v2\//,
    baseAddress: "http://localhost:5086",
  },
  {
    pattern: /./,
    baseAddress: "https://tran-api.signin.education.gov.uk",
  }
];

function resolveTargetUri(path) {
  for (let mapping of pathMappings) {
    if (mapping.pattern.test(path)) {
      return `${mapping.baseAddress}${path}`;
    }
  }
  throw new Error(`Cannot resolve mapping for path '${path}'.`);
}

const server = http.createServer(handler);
const httpListenOnPort = 5086;
server.listen(httpListenOnPort, () => { console.log(`Proxy listening on: ${httpListenOnPort}`) });

function handler(req, res) {
  const originalRequestUrl = req.url;
  const targetUri = resolveTargetUri(url.parse(originalRequestUrl).path);
  const { protocol, hostname, port, path } = url.parse(targetUri);

  const options = {
    hostname,
    port,
    path,
    method: req.method,
    headers: req.headers,
    // minVersion: "TLSv1.3" // Force TLS 1.3
  };

  console.log(`Requesting: ${originalRequestUrl}...`);

  const requestHandler = protocol === "https" ? https : http;
  const proxyReq = requestHandler.request(options, (proxyRes) => {
    const dt = (new Date()).toJSON().slice(0, 19).replace("T", ":")
    console.log(`${dt} ${proxyRes.req.method} ${originalRequestUrl}\n  --> ${proxyRes.statusCode} ${proxyRes.req.protocol}//${proxyRes.req.host}${proxyRes.req.path}`);
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res); // Plain HTTP back
  });

  req.pipe(proxyReq);
  proxyReq.on("error", (err) => {
    console.error(err);
    res.writeHead(500);
    res.end("Proxy error: " + err.message);
  });
}
