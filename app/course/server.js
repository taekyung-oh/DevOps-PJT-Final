/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS'" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 *
 */

'use strict'

const http = require('http');
const AWS = require('aws-sdk');
const fetch = require ("node-fetch");

// config
const create_cfg = require('./config');
const cfg = create_cfg.create_config('./config.yaml');

// tracer
const api = require('@opentelemetry/api'); 
const tracer = api.trace.getTracer('js-sample-app-tracer'); 
const common_span_attributes = { signal: 'trace', language: 'javascript' };
const SpanStatusCode = api.SpanStatusCode

// request metrics 
const { updateTotalBytesSent, updateLatencyTime, updateApiRequestsMetric } = require('./request-metrics');

//logger
const logger = require('./logger')

// start server for request metrics and traces
function startServer() {
    const server = http.createServer(handleRequest);
    server.listen(cfg.Port, cfg.Host, (err) => {
        if (err) {
            throw err;
        }
        logger.info(`Node HTTP listening on ${cfg.Host}:${cfg.Port}`);
    });
}

async function handleRequest(req, res) {
    const requestStartTime = new Date();
    const routeMapper = {
        '/course': (req, res) => {
            res.end('OK.');
        },        
        '/course/courses': getCourses,
        '/course/scheduled': getScheduled,
        '/course/participants' : getParticipants
    }
    try {
        const handler = routeMapper[req.url]
        if (handler) {
            await handler (req, res);
            updateMetrics(res, req.url, requestStartTime);
        };
    } 
    catch (err) {
        logger.error(err.stack);
    }   
}

async function getCourses (req, res) {
    await sleep(1000)

    try {
        const traceid = await instrumentRequest('getCourses', async () => { 
            await httpCall('https://api.bigheadck.click/content/contents')        
            //httpCall('http://localhost:8082/content/contents')
        });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(traceid)
    } catch(err) {
        logger.error(err.stack);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end()
    }
}

async function getScheduled (req, res) {
    try {
        const traceid = await instrumentRequest('getScheduled', async () => {
            res.writeHead(400, { 'Content-Type': 'application/json' });
            res.end()
            throw new Error
        });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(traceid)
    } catch(err) {
        logger.error(err.stack);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end()
    }
}

async function getParticipants (req, res) {
    try {
        const traceid = await instrumentRequest('getParticipants', async () => {
            await httpCall('https://api.bigheadck.click/user/users')        
        });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(traceid)
    } catch(err) {
        logger.error(err.stack);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end()
    }
}

function updateMetrics (res, apiName, requestStartTime) {
    updateTotalBytesSent(res._contentLength + mimicPayLoadSize(), apiName, res.statusCode);
    updateLatencyTime(new Date() - requestStartTime, apiName, res.statusCode);
    updateApiRequestsMetric();
}

function getTraceIdJson() {
    const otelTraceId = api.trace.getSpan(api.context.active()).spanContext().traceId;
    const timestamp = otelTraceId.substring(0, 8);
    const randomNumber = otelTraceId.substring(8);
    const xrayTraceId = "1-" + timestamp + "-" + randomNumber;
    return JSON.stringify({ "traceId": xrayTraceId });
}

function mimicPayLoadSize() {
    return Math.random() * 1000;
}

async function httpCall(url) {
    try {
        const response = await fetch(url);

        logger.info(`made a request to ${url}`);
        
        if (!response.ok) {
            throw new Error(`Error! status: ${response.status}`);
        }
    } catch (err) {
        throw err
    }
}

async function instrumentRequest(spanName, _callback) {
    const span = tracer.startSpan(spanName, {
        attributes: common_span_attributes
    });

    const ctx = api.trace.setSpan(api.context.active(), span);

    let traceid;

    await api.context.with(ctx, async () => {
        traceid = getTraceIdJson();

        try {
            await _callback();

            return traceid;
        } catch(err) {
            span.setStatus({code: SpanStatusCode.ERROR, message: err.stack,});
                
            throw err
        } finally {
            span.end();            
        }
    });
}

const sleep = delay => new Promise(resolve => setTimeout(resolve, delay));

module.exports = {startServer};
