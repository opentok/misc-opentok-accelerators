'use strict';
/* eslint-env es6 */

/** Config */
const apiKey = process.env.API_KEY;
const apiSecret = process.env.API_SECRET;

/** Imports */
const OpenTok = require('opentok');
const OT = new OpenTok(apiKey, apiSecret);

/** Private */

// Sessions need to be updated if we use a different api key
const sessions = [
  '1_MX40NTU4OTAyMn5-MTQ2NDc5NzE5ODUzOH5HazV0QnpCdE9zbVB3cEtuR0hnZGpYUnV-fg',
  '1_MX40NTU4OTAyMn5-MTQ2NjAxODc2NTIzMX5BQy9oMTF3ZTVlSDRORXhRemdONHhEVFB-fg',
  '1_MX40NTU4OTAyMn5-MTQ2NjAxODc3NTk1NH5FZVMweEF5STlOVDAveEtNS2JFUTIwQWF-fg',
  '1_MX40NTU4OTAyMn5-MTQ2NjAxODc4NDY2OH5qWGNjNlNuOExPWmhKOGU1ejBwNE0vdWd-fg',
  '2_MX40NTU4OTAyMn5-MTQ2NjAxODgwMTAzM35BUjE4UE9HWit4RUgzSUkreHQwMkJCQzd-fg',
];

const createToken = session => OT.generateToken(session);

/** Exports */
/**
 * Creates an OpenTok session and generates an associated token
 * @returns {Promise} <Resolve => {Object}, Reject => {Error}>
 */
const getCredentials = route => {
  const sessionId = sessions[Math.min(route, sessions.length - 1) || 0];
  const token = createToken(sessionId);
  return { apiKey, sessionId, token };
};

module.exports = {
  getCredentials
};
