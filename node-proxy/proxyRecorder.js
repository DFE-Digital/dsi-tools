const { EventEmitter } = require("events");
const http = require("http");

// A wrapper around an existing http proxy server that records incoming requests
// and their corresponding responses.  It also provides an http interface to 
// view the captured logs.
class ProxyRecorder extends EventEmitter {

  /*
    Creates an instance of ProxyRecorder.
    @param {http.Server} proxyServer - the existing http proxy server to wrap.
    @param {number} [logPort=8081] - the port on which the log server will be exposed.
  */
  constructor(proxyServer, logPort = 8081) {
    super();
    this.proxyServer = proxyServer;
    this.logPort = logPort;
    this.logs = [];
    this.logServer = null;

    this.attachListeners();
    this.startLogServer();
  }

  // Attaches event listeners to the proxy server to capture requests and responses.
  attachListeners() {
    this.proxyServer.on("request", (req, res) => {
      const startTime = Date.now();
      let requestBody = "";

      // capture request body
      req.on("data", (chunk) => {
        requestBody += chunk
      }); 

      req.on("end", () => {
        const requestLog = {
          timestamp: new Date().toISOString(),
          method: req.method,
          url: req.url,
          headers: req.headers,
          body: requestBody || null,
        };

        let responstBody = "";
        const originalWrite = res.write;
        const originalEnd = res.end;
        
        // capture response body
        res.write = function (chunk) {
          responstBody += chunk.toString();
          originalWrite.apply(res, arguments);
        };

        // override the default 'res.end' method to capture the response body
        res.end = function (chunk) {
          if (chunk) responstBody += chunk.toString();
          originalEnd.apply(res, arguments);
        };

        // capture response metadata once the request finishes
        res.on("finish", () => {
          const responseLog = {
            statusCode: res.statusCode,
            headers: res.getHeaders(),
            body: responstBody,
            duration: Date.now() - startTime,
          };

          const logEntry = { request: requestLog, response: responseLog };
          this.logs.push(logEntry);
        });
      });
    });
  }

  // starts a http server to expose captured logs
  startLogServer() {
    this.logServer = http.createServer((req, res) => {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify(this.logs, null, 2));
    });

    this.logServer.listen(this.logPort, () => {
      console.log(`Log server running on: ${this.logPort}`);
    })
  }
}

module.exports = ProxyRecorder;
