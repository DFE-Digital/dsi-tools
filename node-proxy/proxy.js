const http = require('http');
const https = require('https');
const url = require('url');

const domainMappings = [
  {
    pattern: /^(?!v2)/,
    targetDomain: "api.example.com",
    protocol: "https"
  }
]

const server = http.createServer((req, res) => {
  const target = url.parse(req.url);
  let targetHostname = target.hostname;
  let targetPort = target.port || 443;
  let targetProtocol = "https";

  for(const mapping of domainMappings) {
    if (mapping.pattern.test(target.path)) {
      targetHostname = mapping.targetDomain;
      targetPort = mapping.port;
      targetProtocol = mapping.protocol;
      console.log(`Route overriden to: ${targetProtocol}://${targetHostname}:${targetPort} for path: ${target.path}`)
      break;
    }
  }
  
  const options = {
    hostname: targetHostname,
    port: targetPort,
    path: target.path,
    method: req.method,
    headers: req.headers,
    // minVersion: 'TLSv1.3' // Force TLS 1.3
  };

  const requestHandler = targetProtocol === "https" ? https : http;
  const proxyReq = requestHandler.request(options, (proxyRes) => {
    const dt = (new Date()).toJSON().slice(0,19).replace('T',':')
    console.log(`${dt} ${proxyRes.statusCode} ${proxyRes.req.method} ${proxyRes.req.host} ${proxyRes.req.path}`);
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res); // Plain HTTP back
  });

  req.pipe(proxyReq);
  proxyReq.on('error', (err) => {
    res.writeHead(500);
    res.end('Proxy error: ' + err.message);
  });
});

const listenOnPort = 8080;
server.listen(listenOnPort, () =>{console.log(`Proxy listening on: ${listenOnPort}`)});
