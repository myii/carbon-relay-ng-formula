# -*- coding: utf-8 -*-
# vim: ft=yaml
---
carbon-relay-ng:
  global:
    instance: ${HOST}
    max_procs: 2
    admin_addr: 0.0.0.0:2004
    http_addr: 0.0.0.0:8081
    spool_dir: spool
    pid_file: carbon-relay-ng.pid
    log_level: info
    validation_level_legacy: medium
    validation_level_m20: medium
    validate_order: false
    bad_metrics_max_age: 24h
  instrumentation:
    graphite_addr: localhost:2003
    graphite_interval: 1000
  inputs:
    listen_addr: 0.0.0.0:2003
    pickle_addr: 0.0.0.0:2013
    amqp:
      enabled: false
      host: localhost
      port: 5672
      user: guest
      password: guest
      vhost: /graphite
      exchange: metrics
      queue: ''
      key: '#'
      durable: false
      exclusive: true
  aggregators:
    - function: sum
      prefix: ''
      substr: ''
      regex: ^stats\.timers\.(app|proxy|static)[0-9]+\.requests\.(.*)
      format: stats.timers._sum_$1.requests.$2
      interval: 10
      wait: 20
    - function: avg
      prefix: ''
      substr: requests
      regex: ^stats\.timers\.(app|proxy|static)[0-9]+\.requests\.(.*)
      format: stats.timers._avg_$1.requests.$2
      interval: 5
      wait: 10
  rewriters:
    - old: testold
      new: testnew
      max: -1
    - old: fooold
      new: foonew
      max: -1
  routes:
    - key: carbon-default
      type: sendAllMatch
      prefix: ''
      destinations:
        - 127.0.0.1:2003 spool=true pickle=false
    - key: carbon-tagger
      type: sendAllMatch
      substr: '='
      destinations:
        - 127.0.0.1:2006
    - key: analytics
      type: sendFirstMatch
      regex: (Err/s|wait_time|logger)
      destinations:
        - graphite.prod:2003 prefix=prod. spool=true pickle=true
        - graphite.staging:2003 prefix=staging. spool=true pickle=true
  cmds: []
