const { createProxyServer } = require("./proxy");
const ProxyRecorder = require("./proxyRecorder");

const proxyServer = createProxyServer(8080);
new ProxyRecorder(proxyServer, 8081);
