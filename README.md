<a href="http://promisesaplus.com/">
    <img src="http://promisesaplus.com/assets/logo-small.png" alt="Promises/A+ logo" title="Promises/A+ 1.0 compliant" align="right" />
</a>

bluebird-lru-cache
=========

In-memory, Promises/A+ [lru-cache](https://github.com/isaacs/node-lru-cache) via [bluebird](https://github.com/petkaantonov/bluebird), inspired by [bluecache](https://github.com/kurttheviking/bluecache)


### Motivation

Allow easy use of LRU-Cache within a promise architecture, both accepting and returning promises.


### Usage

```
var BluebirdLRU = require("bluebird-lru-cache");
var options = {
  max: 500,
  maxAge: 1000 * 60 * 60
};

var cache = BluebirdLRU(options);

cache.set("key", "value")
.then(function () {
	return cache.get("key")
})
.then(function (value) {
	console.log(value);  // "value"
});
```


### Options

Options are passed directly to LRU Cache at instantiation; the below documentation is based on the API descriptions of the underlying LRU Cache:

- `max`: The maximum size of the cache, checked by applying the length function to all values in the cache
- `maxAge`: Maximum age in ms; lazily enforced; expired keys will return `undefined`
- `length`: Function called to calculate the length of stored items (e.g. `function(n) { return n.length; }`); defaults to `function(n) { return 1; }`
- `dispose`: Function called on items when they immediately before they are dropped from the cache. Called with parameters (`key`, `value`)
- `stale`: Allow the cache to return the stale (expired via `MaxAge`) value before deleting it
- `noreject`: _bluebird-lru-cache only_; Boolean; instructs bluebird-lru-cache not to generate rejected promises and instead resolve to undefined for missing or expired output from `get` and `peek`;  defaults to `false`


### API

Any of the arguments for these functions can be a promise, which will be resolved before executing the method.

**`set(key, value)`**

Set the given `key` in the cache to `value`; updates the "recently-used"-ness of the key; returns a promise that resolves to a boolean indicating whether the value was stored or not (in the case of the value being too large it will not be stored).

```
var promisedKey = Promise.resolved().delay(500).then(function () {
	return 'foo';
});
var promisedValue = Promise.resolved().delay(500).then(function () {
	return 'bar';
});

cache.set(promisedKey, promisedValue).then(function (cached) {
	console.log(cached);  // => true
});
```


**get(key)**

Returns a promise that resolves to the cached value of `key`; updates the "recently-used"-ness of the key.

In the case of the key not existing, the Promise will be rejected with a `BluebirdLRU.NoSuchKeyError`, with a `key` property that resolves to the key that could not be found.


**peek(key)**

Returns a promise that resolves to the cached value of `key` _without_ updating the "recently-used"-ness of the key.

In the case of the key not existing, the Promise will be rejected with a `BluebirdLRU.NoSuchKeyError`, with a `key` property that resolves to the key that could not be found.


**del(key)**

Returns a promise that resolves to `undefined` after deleting the key from the cache.


**reset()**

Returns a promise that resolves to `undefined` after removing the key from the cache.


**has(key)**

Returns a promise that resolves to either `true` or `false` without updating the "recently-used"-ness; does not impact the use of `stale` data.


**forEach(function(value,key,cache), [thisp])**

Just like `Array.prototype.forEach`.  Iterates over all the keys in the cache, in order of recent-ness.  (Ie, more recently used items are iterated over first.)


**keys()**

Returns a promise that resolves to an array of the keys in the cache.

```
cache.keys().then(function (keys) {
	console.log(keys);
});
```

**values()**

Returns a promise that resolves to an array of the values in the cache.

```
cache.values().then(function (values) {
	console.log(values);
});
```

### Rejection handling

By default BluebirdLRU returns a rejected promise for get/peek operations that fail, as such:

```
var BluebirdLRU = require('bluebird-lru-cache');

var cache = BluebirdLRU();

cache.get('foo').catch(BluebirdLRU.NoSuchKeyError, function (err) {
	console.log('Could not find key:', err.key); // => "Could not find key: foo"
});
```

you can disable this with the `noreject` option:

```
var BluebirdLRU = require('bluebird-lru-cache');

var cache = BluebirdLRU({
  noreject: true
});

cache.get('foo').then(function (value) {
	if (value === undefined) {
		console.log('Could not find key'); // => "Could not find key"
	}
});
```

### Contribute

PRs are welcome! For bugs, please include a failing test which passes when your PR is applied.
