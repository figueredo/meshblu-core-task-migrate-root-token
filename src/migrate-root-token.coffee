http         = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class MigrateRootToken
  constructor: ({ datastore, pepper, uuidAliasResolver }) ->
    @tokenManager = new TokenManager { datastore, pepper, uuidAliasResolver }

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    { uuid, token } = request.metadata.auth

    @tokenManager.storeToken { uuid, token }, (error) =>
      return callback error if error?
      return @_doCallback request, 204, callback

module.exports = MigrateRootToken
