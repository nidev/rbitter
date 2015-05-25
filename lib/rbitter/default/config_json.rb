module Rbitter
  DEFAULT_CONFIG_JSON = <<-ENDOFJSON
{
  "twitter": {
    "consumer_key": "",
    "consumer_secret": "",
    "access_token": "",
    "access_token_secret": "",
    "connection": {
      "reconnect": true,
      "timeout_secs": 5
    }
  },
  "activerecord": "sqlite3",
  "sqlite3": {
    "dbfile": "rbitter.sqlite"
  },
  "mysql2": {
    "host": "localhost",
    "port": 3306,
    "dbname": "archive",
    "username": "",
    "password": ""
  },
  "media_downloader": {
    "large_image": true,
    "download_dir": "imgs/"
  },
  "xmlrpc": {
    "enable": true,
    "bind_host": "0.0.0.0",
    "bind_port": 1400,
    "auth": {
      "username": "username",
      "password": "password"
    },
    "handles": ["/path/to/handles"]
  }
}
ENDOFJSON
end
