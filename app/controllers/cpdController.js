const { v4: uuidv4 } = require("uuid");

exports.generateCPD = (req, res) => {
  res.json({ cpdid: uuidv4() });
};
