const http = require('http');
const https = require('https');
const url = require('url');

const domainMappings = [
  // Reroute to public API in DEV environment.
  {
    sourceDomain: "localhost",
    sourcePort: 5086,
    sourcePattern: /^services\/[^/]+\/organisations\/[^/]+\/users\/[^/]+$/,
    targetDomain: "dev-api.signin.education.gov.uk",
    targetProtocol: "https"
  }
]

const server = http.createServer((req, res) => {
  const originalRequestUrl = req.url;
  const requestedUrl = url.parse(originalRequestUrl);

  let targetHostname = requestedUrl.hostname;
  let targetPort = requestedUrl.port || 443;
  let targetProtocol = "https";

  // console.log(`Requesting: ${req.url}`);

  for (const mapping of domainMappings) {
    if (mapping.sourceDomain === requestedUrl.hostname &&
        mapping.sourcePort === targetPort &&
        mapping.sourcePattern.test(requestedUrl.path)
    ) {
      targetHostname = mapping.targetDomain ?? targetHostname;
      targetPort = mapping.port ?? targetPort;
      targetProtocol = mapping.protocol ?? targetProtocol;
      console.log(`Route overriden to: ${targetProtocol}://${targetHostname}:${targetPort} for path: ${requestedUrl.path}`)
      break;
    }
  }

  if (targetHostname.includes("localhost")) {
    targetProtocol = requestedUrl.protocol;
  }
  
  const options = {
    hostname: targetHostname,
    port: targetPort,
    path: requestedUrl.path,
    method: req.method,
    headers: req.headers,
    // minVersion: 'TLSv1.3' // Force TLS 1.3
  };

  const requestHandler = targetProtocol === "https" ? https : http;
  const proxyReq = requestHandler.request(options, (proxyRes) => {
    const dt = (new Date()).toJSON().slice(0,19).replace('T',':')
    console.log(`${dt} ${proxyRes.req.method} ${originalRequestUrl}\n  --> ${proxyRes.statusCode} ${proxyRes.req.protocol}//${proxyRes.req.host}${proxyRes.req.path}`);
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res); // Plain HTTP back
  });

  req.pipe(proxyReq);
  proxyReq.on('error', (err) => {
    console.error(err);
    res.writeHead(500);
    res.end('Proxy error: ' + err.message);
  });
});

const listenOnPort = 8080;
server.listen(listenOnPort, () =>{console.log(`Proxy listening on: ${listenOnPort}`)});
