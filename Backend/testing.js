const testEmails = [
  `Dear Customer,
Rs.60.00 has been debited from account 5488 to VPA pavithramart.63434836@hdfcbank PAVITHRA MART on 24-07-25.
Your UPI transaction reference number is 108642900372.
If you did not authorize this transaction, please report it immediately by calling 18002586161 Or SMS BLOCK UPI to 7308080808.
Warm Regards,
HDFC Bank`,

  `Rs.75.00 has been debited to VPA pavithramart.63434836@hdfcbank PAVITHRA MART on 01-08-25.
Your UPI transaction reference number is 109128631655.`,

  `Rs.299.00 credited to account 1234 from AmazonMarketplace on 19-08-25.
UPI reference number is 123456789012.`,

  `INR 150.00 debited at STARBUCKS on 20-08-25.
Ref No: 9876543210`,
];

function parseBankMessage(snippet) {
  const result = {
    amount: null,
    vendor: null,
    type: null,
    date: null,
    referenceNumber: null,
  };

  // Amount
  const amtMatch = snippet.match(/(?:Rs\.?|INR)\s*([\d,]+\.?\d*)/i);
  if (amtMatch) result.amount = parseFloat(amtMatch[1].replace(/,/g, ""));

  // Debit / Credit
  if (/debited/i.test(snippet)) result.type = "debit";
  else if (/credited/i.test(snippet)) result.type = "credit";

  // Date
  const dateMatch = snippet.match(/on\s+(\d{2}[-/]\d{2}[-/]\d{2,4})/i);
  if (dateMatch) result.date = dateMatch[1];

  // Reference Number (flexible regex)
  const refMatch = snippet.match(/(?:reference number is|UPI reference number is|Ref No:?)\s*([A-Za-z0-9]+)/i);
  if (refMatch) result.referenceNumber = refMatch[1].trim();

  // Vendor extraction - remove emails, pick last uppercase phrase
  let vendorCandidate = snippet.replace(/[a-z0-9._%+-]+@[a-z0-9.-]+/gi, '').trim();

  const vendorWords = vendorCandidate.match(/(?:\b[A-Z]{2,}\b(?:\s)?)+/g);
  if (vendorWords && vendorWords.length > 0) {
    result.vendor = vendorWords[vendorWords.length - 1].trim();
  } else {
    // Fallback: extract after "to " or "at "
    const toMatch = snippet.match(/to\s+([A-Za-z0-9\s&.-]+)/i);
    if (toMatch) {
      let v = toMatch[1].trim();
      v = v.replace(/[a-z0-9._%+-]+@[a-z0-9.-]+/gi, '').trim();
      v = v.replace(/\s{2,}/g, ' ');
      result.vendor = v;
    }
  }

  return result;
}

console.log("=== Bank Email Regex Test ===");
testEmails.forEach((email, idx) => {
  console.log(`\n-- Email ${idx + 1} --`);
  console.log(email);
  const parsed = parseBankMessage(email);
  console.log("Parsed Result:", parsed);
});
