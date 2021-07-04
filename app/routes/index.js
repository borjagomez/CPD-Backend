var express = require("express");
var router = express.Router();
var cors = require("cors");

var CPDController = require("../controllers/cpdController");

var corsOptions = {
  origin: 'https://cpd-infrastructure.uc.r.appspot.com',
  optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
}

/* GET home page. */
router.get("/", function (req, res, next) {
  res.render("index", { title: "CPD Infrastructure" });
});

router.get("/gencpd", cors(corsOptions), CPDController.generateCPD);

module.exports = router;
