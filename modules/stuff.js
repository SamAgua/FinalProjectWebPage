"use strict";
const crypto = require('crypto');
const OAuth = require('oauth-1.0a');

function hash_function_sha1(base_string, key) {
    return crypto.createHmac('sha1', key).update(base_string).digest('base64');
}

function getOauthHeader(consumerKey, consumerSecret, token, tokenSecret, query) {
    const requestData = {
        url: `https://api.twitter.com/1.1/search/tweets.json?q=${query}`,
        method: 'GET'
    };
    let oauth = OAuth({
        consumer: {key: consumerKey, secret: consumerSecret},
        signature_method: 'HMAC-SHA1',
        hash_function: hash_function_sha1
    });
    let oauthData = oauth.authorize(requestData, {
        key: token,
        secret: tokenSecret
    });
    return oauth.toHeader(oauthData);
};
function gone(consumerKey, consumerSecret, token, tokenSecret,name) {
    const requestData = {
        url: `https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=${name}`,
        method: 'GET'
    };
    let oauth = OAuth({
        consumer: {key: consumerKey, secret: consumerSecret},
        signature_method: 'HMAC-SHA1',
        hash_function: hash_function_sha1
    });
    let oauthData = oauth.authorize(requestData, {
        key: token,
        secret: tokenSecret
    });
    return oauth.toHeader(oauthData);
};

module.exports = {
    getOauthHeader: getOauthHeader,
    TWITTER_CONSUMER_KEY: 'OgmrYFJ151Peo620aqiaSzipx',
    TWITTER_CONSUMER_SECRET: '8qGytaBuNkknvIkmFJkSTz6P0kGHbPCFqnXZ945Dg5XIP5fhxm',
    gone: gone
}
