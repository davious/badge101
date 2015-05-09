jws = require 'jws'
fs = require 'node-fs'
crypto = require 'crypto'

ARGV = process.argv[1..]
if ARGV.length == 2
  badgeName = ARGV[1]
  badgePath =  "#{__dirname}/awards/#{badgeName}"
  if fs.existsSync "#{badgePath}.json"
    assertion = fs.readFileSync "#{badgePath}.json"
  else
    console.log "#{badgeName} not found"
    return
else
  console.log "usage hash-and-sign.coffee badgeName (no .json)"
  return

assertion = JSON.parse assertion

email = assertion.recipient.identity
shaEmail = crypto.createHash('sha256').update(email).digest('hex')
assertion.recipient.identity = 'sha256$' + shaEmail
assertion.recipient.hashed = true
assertion.verify.url = assertion.verify.url.replace(".json", ".hashed.json")
fs.writeFileSync "#{badgePath}.hashed.json", JSON.stringify(assertion, null, '\t')

assertion.verify.type = "signed"
assertion.verify.url = "http://davious.github.io/badge101/public-key.pem"

privateKey = fs.readFileSync "#{__dirname}/private-key.pem"
data =
  header: {alg: 'rs256'}
  payload: assertion
  privateKey: privateKey
signature = jws.sign data

fs.writeFileSync "#{badgePath}.signed.json", signature