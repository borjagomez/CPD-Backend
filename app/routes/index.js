var express = require("express");
var router = express.Router();

var CPDController = require("../controllers/cpdController");

/* GET home page. */
router.get("/", function (req, res, next) {
  res.render("index", { title: "CPD Infrastructure" });
});

router.get("/gencpd", CPDController.generateCPD);

module.exports = router;
