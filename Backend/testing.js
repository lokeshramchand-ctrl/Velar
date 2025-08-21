const testEmails = [
  `Dear Customer, Rs.20.00 has been debited from account 5488 to VPA paytm.s1eeznf@pty SHS CANTEEN 1 on 18-08-25. Your UPI transaction reference number is 109983023268. If you did not authorize this `
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
  if (dateMatch) result.date = dateMatch;

  // Reference number
  const refMatch = snippet.match(/reference number is\s*([\d]+)/i);
  if (refMatch) result.referenceNumber = refMatch.trim();

  // Improved vendor extraction:
  // Try to extract vendor from phrases like "to <vendor>" or "at <vendor>"

  let vendor = null;

  const toMatch = snippet.match(/to\s+([A-Za-z0-9\s.&'-]+)/i);
  if (toMatch) {
    vendor = toMatch.replace(/[a-z0-9._%+-]+@[a-z0-9.-]+/gi, '').trim();
  } else {
    const atMatch = snippet.match(/at\s+([A-Za-z0-9\s.&'-]+)/i);
    if (atMatch) {
      vendor = atMatch.replace(/[a-z0-9._%+-]+@[a-z0-9.-]+/gi, '').trim();
    }
  }

  // Clean extra spaces or trailing punctuation
  if (vendor) {
    vendor = vendor.replace(/\s{2,}/g, ' ').replace(/[.,]$/, '').trim();
  }
  result.vendor = vendor || "Unknown";

  return result;
}


console.log("=== Bank Email Regex Test ===");
testEmails.forEach((email, idx) => {
  console.log(`\n-- Email ${idx + 1} --`);
  console.log(email);
  const parsed = parseBankMessage(email);
  console.log("Parsed Result:", parsed);
});
