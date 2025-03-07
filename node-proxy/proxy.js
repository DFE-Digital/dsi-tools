const http = require('http');
const https = require('https');
const url = require('url');

const server = http.createServer((req, res) => {
  const target = url.parse(req.url);
  const options = {
    hostname: target.hostname,
    port: target.port || 443,
    path: target.path,
    method: req.method,
    headers: req.headers,
    // minVersion: 'TLSv1.3' // Force TLS 1.3
  };

  const proxyReq = https.request(options, (proxyRes) => {
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