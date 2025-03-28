const createProxyServer = require("./proxy");

const domainMappings = [
  {
    pattern: /^\/api\/v1\/.*$/,
    targetDomain: "api.exmaple.com",
    protocol: "https"
  }
]

createProxyServer(8080, domainMappings);
