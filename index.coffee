LRUCache = require 'lru-cache'
Promise = require 'bluebird'

module.exports = class BluebirdLRU extends LRUCache
	# Update these methods of LRUCache to return a promise.
	for method in ['set', 'get', 'peek', 'del', 'reset', 'has', 'keys', 'values']
		do ->
			promisifiedMethod = Promise.method(BluebirdLRU::[method])
			# If the method takes arguments then make sure any promise arguments are resolved before calling the actual method.
			if promisifiedMethod.length > 0
				BluebirdLRU::[method] = ->
					if arguments.length > 0
						Promise.all(arguments).bind(@).spread(promisifiedMethod)
					else
						promisifiedMethod.apply(@, arguments)
			else
				BluebirdLRU::[method] = promisifiedMethod

	# If the user opts in to rejected promises on failed gets/sets then we can return this error
	# Allowing use of `.catch BluebirdLRU.NoSuchKeyError, -> ...`
	BluebirdLRU.NoSuchKeyError = class NoSuchKeyError extends Error
		constructor: (@key) ->
			super

	rejectCheck = (key) ->
		(value) ->
			if value is undefined
				throw new NoSuchKeyError(key)
			return value

	rejectedGet = (key) ->
		BluebirdLRU::get.apply(@, arguments)
		.then rejectCheck(key)

	rejectedPeek = (key) ->
		BluebirdLRU::peek.apply(@, arguments)
		.then rejectCheck(key)

	constructor: (options = {}) ->
		if !(@ instanceof BluebirdLRU)
			return new BluebirdLRU(options)

		super


		if options.fetchFn
			fetchFn = Promise.method(options.fetchFn)
			catchFn = ({key}) =>
				fetchFn(key)
				.tap (value) =>
					@set(key, value)
			@get = ->
				rejectedGet.apply(@, arguments)
				.catch(NoSuchKeyError, catchFn)
			@peek = ->
				rejectedPeek.apply(@, arguments)
				.catch(NoSuchKeyError, catchFn)
		else if !options.noreject
			@get = rejectedGet
			@peek = rejectedPeek
