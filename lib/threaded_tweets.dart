// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

import 'dart:async';

import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
import 'package:actions_toolkit_dart/core.dart' as core;
import 'package:twitter_api_v2/twitter_api_v2.dart';

Future<void> tweet() async {
  final twitter = v2.TwitterApi(
    bearerToken: core.getInput(name: 'bearer_token'),
    oauthTokens: oauthTokens,
    retryConfig: v2.RetryConfig.ofExponentialBackOffAndJitter(
      maxAttempts: 10,
      onExecute: (event) => core.warning(
        message: 'Timeout occurred. Waiting for retry...',
      ),
    ),
  );

  try {
    final responses = await twitter.tweets.createThreads(tweets: tweets);

    core.info(
      message: 'Send threaded tweets successfully!',
    );

    for (final response in responses) {
      core.info(message: 'Sent tweet [tweetId = ${response.data.id}]');
    }
  } on TimeoutException catch (e) {
    core.error(message: e.toString());
  } on v2.UnauthorizedException catch (e) {
    core.error(message: e.toString());
  } on v2.RateLimitExceededException catch (e) {
    core.error(message: e.toString());
  } on v2.TwitterException catch (e) {
    core.error(message: e.toString());
  }
}

v2.OAuthTokens? get oauthTokens {
  if (core.getInput(name: 'consumer-key').isEmpty ||
      core.getInput(name: 'consumer-secret').isEmpty ||
      core.getInput(name: 'access-token').isEmpty ||
      core.getInput(name: 'access-token-secret').isEmpty) {
    return null;
  }

  return v2.OAuthTokens(
    consumerKey: core.getInput(name: 'consumer-key'),
    consumerSecret: core.getInput(name: 'consumer-secret'),
    accessToken: core.getInput(name: 'access-token'),
    accessTokenSecret: core.getInput(name: 'access-token-secret'),
  );
}

List<TweetParam> get tweets => core
    .getMultilineInput(name: 'texts')
    .map((text) => TweetParam(text: text))
    .toList();
