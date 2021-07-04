const { v4: uuidv4 } = require("uuid");
const shellExec = require("shell-exec");
const R = require("r-script");
const { Storage } = require("@google-cloud/storage");

const bucketName = "cpd-images";

exports.generateCPD = (req, res) => {
  const storage = new Storage({ keyFilename: "/tmp/cpd-storage-key.json" });
  const cpdid = uuidv4();
  const destination = `${cpdid}.png`;

  return shellExec("Rscript CPD/streamBTC.R")
  .then(() => {
    return storage.bucket(bucketName).upload("CPD.png", {
      destination,
    })    
  })
  .then(() => {
    return res.json({ cpdid });    
  })
  .catch(console.log);
};
