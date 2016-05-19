/*
 * Express Dependencies
 */
var express = require('express');

var app = express();
var port = 3000;

app.use(express.static([__dirname, '/public'].join('')));

/*
 * Routes
 */
app.get('/', function (req, res) {
  res.render('index.html');
});

app.get('/google721749a8bd473661.html', function (req, res) {
  res.render('google721749a8bd473661.html');
});

app.get('*', function (req, res) {
  res.redirect('/');
});

/*
 * Listen
 */
app.listen(process.env.PORT || port);
console.log(['app listening on port', port].join(' '));
