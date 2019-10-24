"use strict";

const express = require('express');
const hoffman = require('hoffman');
const path = require('path'),
    passport = require('passport'),
    TwitterStrategy = require('passport-twitter').Strategy,
    bodyParser = require('body-parser'),
    authConfig = require('./modules/stuff'),
    authHandling = require('./modules/stuff'),
    https = require('https');

const app = express(); //express module returns a function, not an object!
app.set('views', path.join(__dirname, 'views')); // path to your templates
app.set('view engine', 'dust');
app.engine('dust', hoffman.__express());
app.use('/assets', express.static('assets'));
app.use(bodyParser.urlencoded({
    extended: false
}));
app.use(bodyParser.json());

app.use(require('express-session')({
    secret: 'sooooper secretive secret of secrecy',
    resave: true,
    saveUninitialized: true
}));

app.use(passport.initialize());
app.use(passport.session());

let twitterOptions = {
    consumerKey: authConfig.TWITTER_CONSUMER_KEY,
    consumerSecret: authConfig.TWITTER_CONSUMER_SECRET,
    callbackURL: "http://127.0.0.1:3000/auth/twitter/callback"
};

let twitterAuthStrat = 'twitter-auth';
passport.use(twitterAuthStrat, new TwitterStrategy(twitterOptions,
    (token, tokenSecret, profile, done) => {
        done(null, {
            profile: profile,
            token: token,
            tokenSecret: tokenSecret
        });
    }
));

passport.serializeUser(function (user, cb) {
    cb(null, user);
});

passport.deserializeUser(function (obj, cb) {
    cb(null, obj);
});

let searchOptions = {
    hostname: 'api.twitter.com',
    port: 443,
    path: '/1.1/search/tweets.json',
    method: 'GET',
};

app.get('/second/:whatevs', (request, response) => {
    let user = request.user;
    //console.log(request.user);

    if (user) { //check that they're logged in...
        let hashTag = request.params.whatevs; //Note the use of route parameters to accept any hashtag https://expressjs.com/en/guide/routing.html#route-parameters

        let searchSpecificOptions = Object.assign(searchOptions, {}); //clone the base object so we have a new one on every request

        searchSpecificOptions.path += `?q=${hashTag}`; //Add the search parameter to our request as a query string

        searchSpecificOptions['headers'] = authHandling.getOauthHeader(authConfig.TWITTER_CONSUMER_KEY,
            authConfig.TWITTER_CONSUMER_SECRET,
            user.token,
            user.tokenSecret,
            hashTag); //Add a properly formatted Oauth 1.0 Authorization header to the request

        //Build the HTTP request to Twitter and handle their response
        let requestToTwitter = https.request(searchSpecificOptions, (responseFromTwitter) => {
            let allTweets;
            //console.log(responseFromTwitter);
            responseFromTwitter.on('data', (tweets) => {
                //console.log(tweets);
                if (allTweets) {
                    allTweets += tweets;
                } else {
                    allTweets = tweets;
                }
            });
            responseFromTwitter.on('error', (err) => {
                console.error(err);
            });
            responseFromTwitter.on('end', () => {
                let parsedTweets = JSON.parse(allTweets.toString());
                //console.log(parsedTweets);
                response.render('second', parsedTweets);
            });
        });
        requestToTwitter.end(); //We always have to explicitly end the request

    } else { //If not, we'll send them back to the login page
        response.redirect('/auth/twitter');
    }
});
let myTweetOptions = {
    hostname: 'api.twitter.com',
    port: 443,
    path: '/1.1/statuses/user_timeline.json',
    method: 'GET',
};
app.get("/page3", (request, response) =>{
    let user = request.user;
    let name = user.profile.username;

    if (user) {
        let searchSpecificOptions = Object.assign(myTweetOptions, {}); //clone the base object so we have a new one on every request

        searchSpecificOptions.path += `?screen_name=${name}`; //Add the search parameter to our request as a query string

        searchSpecificOptions['headers'] = authHandling.gone(authConfig.TWITTER_CONSUMER_KEY,
            authConfig.TWITTER_CONSUMER_SECRET,
            user.token,
            user.tokenSecret,
            name);
        let requestToTwitter = https.request(searchSpecificOptions, (responseFromTwitter) => {
            let Tweet;
            //  console.log(responseFromTwitter);
            responseFromTwitter.on('data', (tweets) => {
                if (Tweet) {
                    Tweet += tweets;
                } else {
                    Tweet = tweets;
                }
            });
            responseFromTwitter.on('error', (err) => {
                console.error(err);
            });
            responseFromTwitter.on('end', () => {
                let parsedTweets = JSON.parse(Tweet.toString());
                //  console.log(parsedTweets[0].text);
                //  console.log(parsedTweets.text);
                response.render('page3', parsedTweets[0]);
            });
        });
        requestToTwitter.end(); //We always have to explicitly end the request

    } else { //If not, we'll send them back to the login page
        response.redirect('/auth/twitter');
    }
});

app.get("/fourth", (request, response) =>{
    if (request.user) {
    //console.log(request.user.profile);
        response.render('fourth', request.user.profile._json);
    //authConfig.gone();
    } else{
        response.render('final', {});
    }
});

app.get("/", function (request, response) {
    if (request.user) {
        //console.log(request.user.profile);
        response.render('final', request.user.profile._json);
        //authConfig.gone();
    } else{
        response.render('final', {});
    }
});


app.get('/auth/twitter', passport.authenticate(twitterAuthStrat));

app.get('/auth/twitter/callback',  passport.authenticate(twitterAuthStrat, {
    successRedirect: '/',
    failureRedirect: '/'
}));


app.listen(3000, function () {
    console.log("My app is listening on port 3000!");
});
