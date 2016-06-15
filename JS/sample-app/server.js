/*
 * Express Dependencies
 */
const express = require('express');
const app = express();
const port = 3000;

app.use(express.static([__dirname, '/public'].join('')));
app.set('views', `${__dirname}/views`);
app.set('view engine', 'ejs');

/*
 * Routes
 */
const api = require('./services/api');
app.get('/', (req, res) => {
  const credentials = api.getCredentials(0);
  res.render('index', { credentials: JSON.stringify(credentials) });
});

app.get('/google721749a8bd473661.html', (req, res) => {
  res.render('google721749a8bd473661');
});

app.get('/:session', (req, res) => {
  const session = req.params.session;
  const credentials = api.getCredentials(session);
  res.render('index', { credentials: JSON.stringify(credentials) });
});


app.get('*', (req, res) => {
  res.redirect('/');
});

/*
 * Listen
 */
app.listen(process.env.PORT || port);
console.log(['app listening on port', port].join(' '));
