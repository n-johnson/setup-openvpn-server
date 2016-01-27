module.exports = {
  digitalocean: 'YOUR_API_KEY_HERE',
  opts: {
    "name": String(Math.random()).slice(2,16) + '.net',
    "region": "sfo1",
    "size": "512mb",
    "image": "ubuntu-14-04-x64",
    "ssh_keys": ['YOUR_SSH_KEY_ID_HERE'],
    "backups": false,
    "ipv6": false,
    "private_networking":false
 }
}
