const http = require('http');
const https = require('https');
const net = require('net');
const url = require('url');

function createProxyServer(listenOnPort, domainMappings) {
  const server = http.createServer((req, res) => {
    const target = url.parse(req.url);
    let targetHostname = target.hostname;
    let targetProtocol = req.socket.encrypted ? "https" : "http";

    for(const mapping of domainMappings) {
      if (mapping.pattern.test(target.path)) {
        targetHostname = mapping.targetDomain;
        targetProtocol = mapping.protocol;
        console.log(`Route overriden to: ${targetProtocol}://${targetHostname} for path: ${target.path}`)
        break;
      }
    }
    
    const options = {
      hostname: targetHostname,
      path: target.path,
      method: req.method,
      headers: req.headers,
      // minVersion: 'TLSv1.3' // Force TLS 1.3
    };

    const requestHandler = targetProtocol === "https" ? https : http;
    const proxyReq = requestHandler.request(options, (proxyRes) => {
      const dt = (new Date()).toJSON().slice(0,19).replace('T',':')
      console.log(`${dt} ${proxyRes.statusCode} ${targetProtocol} ${proxyRes.req.method} ${proxyRes.req.host} ${proxyRes.req.path}`);

      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res); // Plain HTTP back
    });

    req.pipe(proxyReq);

    proxyReq.on('error', (err) => {
      console.log(`Proxy error: ${err.message}`);
      res.writeHead(500);
      res.end(`Proxy error: ${err.message}`);
    });
  });

  server.on("connect", (req, clientSocket, head) => {
    
    const [hostname, port] = req.url.split(":");
    const targetPort = port || 443;

    console.log(`CONNECT request for ${hostname}:${targetPort}`);

    const serverSocket = net.connect(targetPort || 443, hostname, () => {
      console.log(`Tunnel established to ${hostname}:${targetPort}`);
      clientSocket.write("HTTP/1.1 200 Connection Established\r\n\r\n");
      serverSocket.write(head);
      serverSocket.pipe(clientSocket);
      clientSocket.pipe(serverSocket);
    });

    serverSocket.on("error", (err) => {
      console.log(`Tunnel error: ${err.message}`);
      clientSocket.write("HTTP/1.1 502 Bad Gateway\r\n\r\n");
      clientSocket.end();
    });

    clientSocket.on("error", (err) => {
      console.log(`Client socket error: ${err.message}`);
      serverSocket.end();
    });
  });

  server.listen(listenOnPort, () =>{
    console.log(`Proxy listening on: ${listenOnPort}`);
  });

  return server;
}

module.exports = createProxyServer;
