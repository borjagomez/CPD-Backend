const { v4: uuidv4 } = require("uuid");
const R = require("r-script");
const { Storage } = require("@google-cloud/storage");

const bucketName = "cpd-images";

exports.generateCPD = (req, res) => {
  const storage = new Storage({ keyFilename: "/tmp/cpd-storage-key.json" });
  const cpdid = uuidv4();
  const destination = `${cpdid}.png`;

  try {
    R("CPD/streamBTC.R").callSync();
  } catch (err) {
    console.log(err);
  }

  async function uploadFile() {
    await storage.bucket(bucketName).upload("CPD.png", {
      destination,
    });

    console.log(`${destination} uploaded to ${bucketName}`);
  }

  uploadFile().catch(console.error);

  res.json({ cpdid });
};
