const { google } = require('googleapis');

exports.fetchBankEmails = async (accessToken, bankEmails) => {
const oauth2Client = new google.auth.OAuth2();
  oauth2Client.setCredentials({ access_token: accessToken });

  const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

  const allEmails = [];

  for (const bankEmail of bankEmails) {
    const res = await gmail.users.messages.list({
      userId: 'me',
      q: `from:${bankEmail}`,
      maxResults: 20, 
    });

    const messages = res.data.messages || [];
    for (const msg of messages) {
      const fullMessage = await gmail.users.messages.get({
        userId: 'me',
        id: msg.id,
      });

      let body = "";
      if (fullMessage.data.payload?.parts) {
        for (const part of fullMessage.data.payload.parts) {
          if (part.mimeType === "text/plain" && part.body?.data) {
            body += Buffer.from(part.body.data, "base64").toString("utf-8");
          }
          if (part.mimeType === "text/html" && part.body?.data) {
            body += Buffer.from(part.body.data, "base64").toString("utf-8");
          }
        }
      }
      const snippet = body || fullMessage.data.snippet || "";
      allEmails.push({
        from: bankEmail,
        snippet,
      });
    }
  }

  return allEmails;
}

