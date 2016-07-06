Datastore        = require 'meshblu-core-datastore'
TokenManager     = require 'meshblu-core-manager-token'
mongojs          = require 'mongojs'
MigrateRootToken = require '../'

describe 'MigrateRootToken', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    database = mongojs 'meshblu-core-task-check-token', ['tokens']
    @datastore = new Datastore
      database: database
      collection: 'tokens'

    database.tokens.remove done

  beforeEach ->
    pepper = 'totally-a-secret'
    @sut = new MigrateRootToken { @datastore, pepper, @uuidAliasResolver }
    @tokenManager = new TokenManager { @datastore, pepper, @uuidAliasResolver }

  describe '->do', ->
    describe 'when called', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'some-uuid'
              token: 'some-token'
          rawData: '{}'

        @sut.do request, (error, @response) => done error

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

      it 'should exist in the database', (done) ->
        @tokenManager.verifyToken { uuid: 'some-uuid', token: 'some-token' }, (error, valid) =>
          return done error if error?
          expect(valid).to.be.true
          done()
