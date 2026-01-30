const { ConfidentialClientApplication } = require("@azure/msal-node");

const params = JSON.parse(process.env.PARAMS);

(async () => {
    const cca = new ConfidentialClientApplication({
        auth: {
            authority: `${params.hostUrl}/${params.tenant}`,
            clientId: params.clientId,
            clientSecret: params.clientSecret,
        },
    });

    const response = await cca.acquireTokenByClientCredential({
        scopes: [`${params.resource}/.default`],
    });

    console.log(response.accessToken);
})();
