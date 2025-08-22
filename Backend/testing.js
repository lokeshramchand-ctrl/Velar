const testEmails = [
  `Dear Customer, Rs.20.00 has been debited from account 5488 to VPA paytm.s1eeznf@pty SHS CANTEEN 1 on 18-08-25. Your UPI transaction reference number is 109983023268. If you did not authorize this `
];

function parseBankMessage(email) {
  const result = {
    amount: null,
    vendor: null,
    rawVendor: null,
    type: null,
    date: null,
    referenceNumber: null,
  };

  // ---------- Amount ----------
  const amtMatch = email.match(/(?:Rs\.?|INR)\s*([\d,]+\.?\d*)/i);
  if (amtMatch) result.amount = parseFloat(amtMatch[1].replace(/,/g, ""));

  // ---------- Debit / Credit ----------
  if (/debited/i.test(email)) result.type = "debit";
  else if (/credited/i.test(email)) result.type = "credit";

  // ---------- Date ----------
  const dateMatch = email.match(/on\s+(\d{2}[-/]\d{2}[-/]\d{2,4})/i);
  if (dateMatch) result.date = dateMatch[1];

  // ---------- Reference Number ----------
  const refMatch = email.match(/(?:reference number is|UPI transaction reference number is|Ref No:?)\s*([A-Za-z0-9]+)/i);
  if (refMatch) result.referenceNumber = refMatch[1].trim();

  // ---------- Vendor Extraction ----------
  let vendorCandidate = null;

  // 1. Prefer "to VPA ..." pattern, stop at 'on|your|Ref|Txn' etc.
  const toMatch = email.match(/to\s+(?:VPA\s+)?(?:[^\s@]+\@[^\s]+\s+)?([A-Za-z0-9\s&.-]+)/i);
  if (toMatch) {
    vendorCandidate = toMatch[1]
      .split(/ on | your | ref | txn | transaction | number /i)[0]  // cut off junk
      .trim();
  }

  // 2. Fallback: fully uppercase phrases
  if (!vendorCandidate) {
    const upperMatch = email.match(/(?:\b[A-Z][A-Z0-9&.-]+\b(?:\s)?)+/g);
    if (upperMatch) {
      vendorCandidate = upperMatch[upperMatch.length - 1].trim();
    }
  }

  // Assign rawVendor
  if (vendorCandidate) {
    result.rawVendor = vendorCandidate;
  }

  // ---------- Cleaning Pipeline ----------
  if (result.rawVendor) {
    let v = result.rawVendor;

    // Remove noise keywords
    v = v.replace(/\b(?:UPI|VPA|REF|Txn|Order|Payment|NEFT|IMPS|Transaction|Number|Your)\b/gi, "");

    // Remove emails
    v = v.replace(/[a-z0-9._%+-]+@[a-z0-9.-]+/gi, "");

    // Remove dates & numbers that sneak in
    v = v.replace(/\d{2}[-/]\d{2}[-/]\d{2,4}/g, "");
    v = v.replace(/\b\d{6,}\b/g, ""); // strip long numbers like reference ids

    // Replace underscores/dashes with space
    v = v.replace(/[_\-]+/g, " ");

    // Collapse multiple spaces
    v = v.replace(/\s{2,}/g, " ").trim();

    // Normalize casing
    v = v.toLowerCase().replace(/\b\w/g, (c) => c.toUpperCase());

    result.vendor = v;
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
