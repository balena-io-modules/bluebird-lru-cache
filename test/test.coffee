chai = require('chai')
chaiAsPromised = require('chai-as-promised')

chai.use(chaiAsPromised)
{expect} = chai

LRU = require('lru-cache')
BluebirdLRU = require('../index')
Promise = require('bluebird')

key = 'foo'
value = 'bar'

describe 'Matching lru-cache API', ->
	bcache = BluebirdLRU(noreject: true)
	lcache = LRU()

	matchingApi = (method, args...) ->
		result = bcache[method](args...)
		expected = lcache[method](args...)
		expect(result).to.eventually.deep.equal(expected)

	fetchTests = ->
		it 'get', ->
			matchingApi('get', key)

		it 'peek', ->
			matchingApi('peek', key)

		it 'has', ->
			matchingApi('has', key)

		it 'keys', ->
			matchingApi('keys')

		it 'values', ->
			matchingApi('values')

	describe 'after set', ->
		it 'set', ->
			matchingApi('set', key, value)

		fetchTests()

	describe 'after delete', ->
		it 'del', ->
			matchingApi('del', key)

		fetchTests()

	describe 'after reset', ->
		it 'set again', ->
			matchingApi('set', key, value)

		it 'reset', ->
			matchingApi('reset', key)

		fetchTests()

describe 'Rejection divergence', ->
	bcache = BluebirdLRU()

	rejectionApi = (method, args...) ->
		result = bcache[method](args...)
			.then -> throw new Error()
			.catch BluebirdLRU.NoSuchKeyError, (err) -> err.key
		expect(result).to.eventually.equal(key)

	it 'get', ->
		rejectionApi('get', key)

	it 'peek', ->
		rejectionApi('peek', key)


describe 'Automatic fetching', ->
	bcache = BluebirdLRU(
		fetchFn: (key) ->
			return key + 'bar'
	)

	autoFetchApi = (method, args...) ->
		result = bcache[method](args...)
		expect(result).to.eventually.equal(key + 'bar')

	it 'get', ->
		autoFetchApi('get', key)

	it 'peek', ->
		bcache.reset().then ->
			autoFetchApi('peek', key)
