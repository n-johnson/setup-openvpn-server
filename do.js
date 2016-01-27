// Import a module
const Promise = require('bluebird')
const DigitalOceanAPI = require('doapi')

const config = loadConfig()

// Create an instance with your API V2 credentials
const api = new DigitalOceanAPI({ token: config.digitalocean })

const ip = api.dropletNew(config.opts)
  .then(getId)
  .then(api.dropletGet)
  .then(getDropletNetwork)
  .catch(exit)

displayIP(ip);

function loadConfig() {
  const isConfigSetup = require('fs').existsSync('config.js')

  if (!isConfigSetup) {
    console.log('Config.js file missing!')
    console.log('Copy config.example.js to config.js and fill in your digital ocean API key')
    return exit(new Error('MISSING_CONFIG_ERROR'))
  }

  return require('./config')
}

function debug() {
  if ((process.env.DEBUG === 'true')) return console.log.apply(console, [].slice.apply(arguments))
}

const exit = (e) => {
  console.log(e)
  process.exit(1)
}

function getDropletNetwork(d) {
  debug('getDropletNetwork');
  if (!d || !d.networks ) return Promise.reject(new Error('Invalid droplet'))

  if (d.networks.v4.length > 0) {
    debug('getDropletNetwork resolving with: %j', d.networks)
    return Promise.resolve(d.networks)
  } else {
    debug('getDropletNetwork: not yet populated, retrying...')
    return Promise.delay(2000, d.id)
             .then(api.dropletGet)
             .then(getDropletNetwork)

  }  
}

function display(ip) {
  debug('display', ip)
  const address = ip && ip.v4 && ip.v4[0] && ip.v4[0].ip_address
  
  if (!address) {
    return Promise.reject(new Error('Invalid networking format:\n' + JSON.stringify(ip)))
  }

  console.log(address)
  return Promise.resolve(ip)
}

function displayIP(ip) {
  ip
    .then(display)
    .catch(exit)
}

function getId(d) {
  return (d && d.id)
    ? Promise.resolve(d.id)
    : Promise.reject(new Error('getId invalid data'))
}
