StatsD = require('lynx')
statsd = new StatsD(process.env["STATSD_HOST"] or "localhost", 8125, {on_error:->})

prom = require('prom-client')
Register = require('prom-client').register
collectDefaultMetrics = prom.collectDefaultMetrics

name = "unknown"
hostname = require('os').hostname()

buildKey = (key)-> "#{name}.#{hostname}.#{key}"
buildGlobalKey = (key)-> "#{name}.global.#{key}"

promMetrics = {}

destructors = []

require "./uv_threadpool_size"

module.exports = Metrics =
	initialize: (_name) ->
		name = _name
		collectDefaultMetrics({ timeout: 5000, prefix: name+"_"})

	registerDestructor: (func) ->
		destructors.push func

	injectMetricsRoute: (app) ->
		app.get('/metrics', (req, res) -> 
			res.set('Content-Type', Register.contentType)
			res.end(Register.metrics())
		)

	sanitizeKey: (key) ->
		key.replace /[^a-zA-Z0-9]/g, "_"

	sanitizeValue: (value) ->
		parseFloat(value)

	set : (key, value, sampleRate = 1)->
		statsd.set buildKey(key), value, sampleRate

	inc : (key, sampleRate = 1)->
		statsd.increment buildKey(key), sampleRate
		key = this.sanitizeKey(key)
		if !promMetrics[key]?
			promMetrics[key] = new prom.Counter({
				name: "#{name}_#{key}",
				help: key, 
				labelNames: ['name','host']
			})
		promMetrics[key].inc({name: name, host: hostname})

	count : (key, count, sampleRate = 1)->
		statsd.count buildKey(key), count, sampleRate

	timing: (key, timeSpan, sampleRate)->
		statsd.timing(buildKey(key), timeSpan, sampleRate)

	Timer : class
		constructor :(key, sampleRate = 1)->
			this.start = new Date()
			this.key = key
			this.sampleRate = sampleRate

		done:->
			timeSpan = new Date - this.start
			statsd.timing(buildKey(this.key), timeSpan, this.sampleRate)
			if !promMetrics[this.key]
				promMetrics[this.key] = new prom.Summary({
					name: "#{name}_timer_#{this.key}".replace(/\./g,"_"),
					help: this.key,
					maxAgeSeconds: 600,
					ageBuckets: 10
				})
			promMetrics[this.key].observe(timeSpan)
			return timeSpan

	gauge : (key, value, sampleRate = 1)->
		statsd.gauge buildKey(key), value, sampleRate
		key = this.sanitizeKey(key)
		if !promMetrics[key]
			promMetrics[key] = new prom.Gauge({
				name: "#{name}_#{key}",
				help: key, 
				labelNames: ['name','host']
			})
		promMetrics[key].set({name: name, host: hostname}, this.sanitizeValue(value))

	globalGauge: (key, value, sampleRate = 1)->
		statsd.gauge buildGlobalKey(key), value, sampleRate
		key = this.sanitizeKey(key)
		if !promMetrics[key]
			promMetrics[key] = new prom.Gauge({
				name: "#{name}_#{key}",
				help: key, 
				labelNames: ['name','host']
			})
		promMetrics[key].set({name: name},this.sanitizeValue(value))

	mongodb: require "./mongodb"
	http: require "./http"
	open_sockets: require "./open_sockets"
	event_loop: require "./event_loop"
	memory: require "./memory"

	timeAsyncMethod: require('./timeAsyncMethod')

	close: () ->
		for func in destructors
			func()
		statsd.close()
