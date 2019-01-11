---
title: "Third Party Licenses"
weight: 8
---

## Docker Images

Our docker images are based on Ubuntu and uses the freely redistributable Zulu VM,
which is based on OpenJDK.

- Ubuntu: [Release Notes Here](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes)
- [Zulu VM](http://zulu.org) is a release of [OpenJDK](http://openjdk.java.net/) provided by Azul Systems Inc.

Docker images also contain copies of Apache Zookeeper and Apache Kafka

- Apache Zookeeper: Used under [Apache License, Version 2](http://www.apache.org/licenses/LICENSE-2.0.txt).

- Apache Kafka: Used under [Apache License, Version 2](http://www.apache.org/licenses/LICENSE-2.0.txt).

```
Apache Kafka
Copyright 2017 The Apache Software Foundation.

This product includes software developed at
The Apache Software Foundation (http://www.apache.org/).

This distribution has a binary dependency on jersey, which is available under the CDDL
License. The source code of jersey can be found at https://github.com/jersey/jersey/.

```

## Java/Scala Dependencies

License | Dependency | Attribution
--- | --- | ---
[BSD 3-Clause License](https://asm.ow2.io/license.html) | # org.ow2.asm # asm # 7.0 | Copyright (c) 2000-2011 INRIA, France Telecom
[BSD 3-Clause License](https://asm.ow2.io/license.html) | # org.ow2.asm # asm-commons # 7.0 | Copyright (c) 2000-2011 INRIA, France Telecom
[BSD 3-Clause License](https://asm.ow2.io/license.html) | # org.ow2.asm # asm-tree # 7.0 | Copyright (c) 2000-2011 INRIA, France Telecom
[BSD 3-Clause License](https://asm.ow2.io/license.html) | # org.ow2.asm # asm-analysis # 7.0 | Copyright (c) 2000-2011 INRIA, France Telecom
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | # net.java.dev.jna # jna # 5.1.0 | Copyright by the authors. [LICENSE](https://github.com/java-native-access/jna/blob/master/LICENSE)
[Apache License, Version 2.0](https://github.com/lomigmegard/akka-http-cors/blob/master/LICENSE) | ch.megard # akka-http-cors_2.12 # 0.3.1 | Copyright (c) Lomig Mégard
[Apache License, Version 2.0](https://github.com/spray/spray-json/blob/master/LICENSE) | io.spray # spray-json_2.12 # 1.3.4 | Copyright (c) 2009-2011 Debasish Ghosh & Mathias Doenitz
[Apache License, Version 2.0](https://github.com/dropwizard/metrics/blob/master/LICENSE) | com.yammer.metrics # metrics-core # 4.0.5 | Copyright 2010-2013 Coda Hale and Yammer, Inc. [NOTICE](https://github.com/dropwizard/metrics/blob/4.1-development/NOTICE)
[Apache License, Version 2.0](https://github.com/dropwizard/metrics/blob/master/LICENSE) | com.yammer.metrics # metrics-jmx # 4.0.5 | Copyright 2010-2013 Coda Hale and Yammer, Inc. [NOTICE](https://github.com/dropwizard/metrics/blob/4.1-development/NOTICE)
[Apache License, Version 2.0](https://github.com/dropwizard/metrics/blob/master/LICENSE) | com.yammer.metrics # metrics-bom # 4.0.5 | Copyright 2010-2013 Coda Hale and Yammer, Inc. [NOTICE](https://github.com/dropwizard/metrics/blob/4.1-development/NOTICE)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | commons-io # commons-io # 2.6 | Copyright 2002-2016 The Apache Software Foundation. [NOTICE](https://git-wip-us.apache.org/repos/asf?p=commons-io.git;a=blob_plain;f=NOTICE.txt;hb=92a07f9aa109f0f55af963f86e466c80718f9466)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | commons-net # commons-net # 3.6 | Copyright 2001-2017 by The Apache Software Foundation. [NOTICE](https://github.com/apache/commons-net/blob/trunk/NOTICE.txt)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.sangria-graphql # sangria # 1.3.0 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.sangria-graphql # sangria-spray-json # 1.0.0 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.sangria-graphql # sangria-streaming-api # 1.0.0 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.sangria-graphql # sangria-marshalling-api # 1.0.0 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.sangria-graphql # macro-visit # 1.0.0 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.sangria-graphql # sangria-slowlog 0.1.6 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | io.dropwizard.metrics # metrics-core # 4.0.3 | Copyright 2010-2013 Coda Hale and Yammer, Inc. [NOTICE](https://github.com/dropwizard/metrics/blob/4.0-development/NOTICE)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.apache.commons # commons-csv # 1.6 | Copyright 2002-2016 The Apache Software Foundation. [NOTICE](https://github.com/apache/commons-csv/blob/master/NOTICE.txt)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.apache.commons # commons-lang3 # 3.8.1 | Copyright 2002-2016 The Apache Software Foundation.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.cache2k # cache2k-api # 1.2.0.Final | Copyright (C) 2000 - 2017 headissue GmbH, Munich
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.cache2k # cache2k-core # 1.2.0.Final | Copyright (C) 2000 - 2017 headissue GmbH, Munich
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.cache2k # cache2k-jmx-api # 0.23.1 | Copyright (C) 2000 - 2017 headissue GmbH, Munich
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.clearspring.analytics # stream # 2.9.6 | Copyright (C) 2012 Clearspring Technologies, Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe # config # 1.3.2 | Copyright (C) 2011-2012 Typesafe Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe # ssl-config-core_2.12 # 0.3.6 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe.akka # akka-actor_2.12 # 2.5.19 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe.akka # akka-protobuf_2.12 # 2.5.19 | Copyright 2018 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe.akka # akka-stream-testkit_2.12 # 2.5.19 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe.akka # akka-stream_2.12 # 2.5.19 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.typesafe.akka # akka-testkit_2.12 # 2.5.19 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | commons-codec # commons-codec # 1.11 | Copyright (c) 2002-2016 The Apache Software Foundation [NOTICE](https://github.com/apache/commons-codec/blob/trunk/NOTICE.txt)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html) | it.unimi.dsi # fastutil # 8.1.1 | Copyright (C) 2002-2017 Sebastiano Vigna
[Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0) | com.typesafe.akka # akka-http-core_2.12 # 10.1.7 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0) | com.typesafe.akka # akka-http-spray-json_2.12 # 10.1.07 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0) | com.typesafe.akka # akka-http-testkit_2.12 # 10.1.07 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0) | com.typesafe.akka # akka-http_2.12 # 10.1.07 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0) | com.typesafe.akka # akka-parsing_2.12 # 10.1.05 | Copyright 2009-2017 Lightbend Inc.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | uk.co.real-logic # Agrona # 0.4.12 | Copyright 2014-2017 Real Logic Ltd.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.101tec # zkclient # 0.10 | Copyright 2010 the original author or authors
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.fasterxml.jackson.core # jackson-annotations # 2.9.5xo | Copyright (c) 2007- Tatu Saloranta, tatu.saloranta@iki.fi
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.fasterxml.jackson.core # jackson-core # 2.9.3 | Copyright (c) 2007- Tatu Saloranta, tatu.saloranta@iki.fi
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.fasterxml.jackson.core # jackson-databind # 2.9.3 | Copyright (c) 2007- Tatu Saloranta, tatu.saloranta@iki.fi
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.googlecode.java-ipv6 # java-ipv6 # 0.17 | Copyright 2013 Jan Van Besien [NOTICE](https://github.com/janvanbesien/java-ipv6/blob/master/NOTICE)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.tdunning # t-digest # 3.1 | The code for the t-digest was originally authored by Ted Dunning
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.yahoo.datasketches # sketches-core # 0.10.3 |
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.yahoo.datasketches # memory # 0.10.3 |
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.lz4 # lz4-java # 1.5 |  Copyright Adrien Grand.  LZ4 is Copyright (c) 2011-2014, Yann Collet [NOTICE](https://github.com/lz4/lz4-java/blob/master/src/lz4/LICENSE)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.kafka # kafka-clients # 1.0.1 | Copyright 2017 The Apache Software Foundation.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.kafka # kafka_2.12 # 1.0.1 |  Copyright 2017 The Apache Software Foundation. [NOTICE](https://github.com/apache/kafka/blob/trunk/NOTICE)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.zookeeper # zookeeper # 3.4.10 | Copyright 2009-2014 The Apache Software Foundation. [NOTICE](https://github.com/apache/zookeeper/blob/master/NOTICE.txt)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.scalatra.scalate # scalate-core_2.12 # 1.8.0 | Copyright 2009-2010 Progress Software Corporation [NOTICE](https://github.com/scalate/scalate/blob/master/notice.md)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.scalatra.scalate # scalate-util_2.12 # 1.8.0 | Copyright 2009-2010 Progress Software Corporation [NOTICE](https://github.com/scalate/scalate/blob/master/notice.md)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.xerial.snappy # snappy-java # 1.1.2.6 | Copyright 2011 Taro L. Saito. [NOTICE](https://github.com/xerial/snappy-java/blob/master/NOTICE)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.github.davidmoten # flatbuffers-java # 1.9.0.1 | Copyright (C) By Google.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.chuusai # shapeless_2.12 # 0.3.0 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | org.typelevel # macro-compat_2.12 # 1.1.1 | Copyright by the authors.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.maxmind.db # maxmind-db # 1.2.2 | Copyright by MaxMind
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | com.maxmind.geoip2 # geoip2 # 2.12.0 | Copyright by MaxMind
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | io.opentracing.contrib # opentracing-scala-concurrent_2.12 # 0.0.4 | Copyright 2018 The OpenTracing Authors
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | io.opentracing # opentracing-api_2.12 # 0.31.0 | Copyright 2018 The OpenTracing Authors
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | io.opentracing # opentracing-mock_2.12 # 0.31.0 | Copyright 2018 The OpenTracing Authors
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | io.opentracing # opentracing-noop_2.12 # 0.31.0 | Copyright 2018 The OpenTracing Authors
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) | io.opentracing # opentracing-util_2.12 # 0.31.0 | Copyright 2018 The OpenTracing Authors
[BSD 2-Clause License](http://opensource.org/licenses/BSD-2-Clause) | com.jcraft # jzlib # 1.1.3 | Copyright by the authors
[BSD 2-Clause License](http://opensource.org/licenses/BSD-2-Clause) | dnsjava # dnsjava # 2.1.8 | Copyright (c) 2004 Brian Wellington (bwelling@xbill.org)
[BSD 3-Clause](http://www.scala-lang.org/license.html) | org.scala-lang # scala-compiler # 2.12.2 | Copyright (c) 2002-  EPFL, Copyright (c) 2011-  Lightbend, Inc.
[BSD 3-Clause](http://www.scala-lang.org/license.html) | org.scala-lang # scala-library # 2.12.2 | Copyright (c) 2002-  EPFL, Copyright (c) 2011-  Lightbend, Inc.
[BSD 3-Clause](http://www.scala-lang.org/license.html) | org.scala-lang # scala-reflect # 2.12.2 | Copyright (c) 2002-  EPFL, Copyright (c) 2011-  Lightbend, Inc.
[BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause) | org.scala-lang.modules # scala-java8-compat_2.12 # 0.8.0 | Copyright (c) 2002-  EPFL, Copyright (c) 2011-  Lightbend, Inc.
[BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause) | org.scala-lang.modules # scala-parser-combinators_2.12 # 1.1.0 | Copyright (c) 2002-2013 EPFL Copyright (c) 2011-2013 Typesafe, Inc.
[BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause) | org.scala-lang.modules # scala-xml_2.12 # 1.0.6 | Copyright (c) 2002-2017  EPFL, Copyright (c) 2011-2017  Lightbend, Inc.
[CC Public Domain](https://creativecommons.org/publicdomain/zero/1.0/) | org.reactivestreams # reactive-streams # 1.0.2 | [Copyright Waiver](https://github.com/reactive-streams/reactive-streams-jvm/blob/master/CopyrightWaivers.txt)
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.logging.log4j # log4j-api # 2.11.1 | Copyright 1999-2017 The Apache Software Foundation.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.logging.log4j # log4j-core # 2.11.1 | Copyright 1999-2017 The Apache Software Foundation.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.logging.log4j # log4j-1.2-api # 2.11.1 | Copyright 1999-2017 The Apache Software Foundation.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | org.apache.logging.log4j # log4j-slf4j-impl # 2.11.1 | Copyright 1999-2017 The Apache Software Foundation.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt) | com.lmax # disruptor # 3.4.2 | Copyright 2017 LMAX-Exchange
[MIT License](http://www.opensource.org/licenses/mit-license.php) | org.slf4j # slf4j-api # 1.7.25 | Copyright (c) 2004-2017 QOS.ch
[MIT License](http://www.opensource.org/licenses/mit-license.php) | net.sf.jopt-simple # jopt-simple # 5.0.4 | Copyright (c) 2004-2016 Paul R. Holser, Jr.
[MIT License](https://raw.githubusercontent.com/auth0/java-jwt/master/LICENSE) | com.auth0 # java-jwt # 3.4.1 | Copyright (c) 2015 Auth0, Inc.
[Bouncy Castle Licence](http://www.bouncycastle.org/licence.html) | org.bouncycastle # bcprov-jdk15on # 1.55 | Copyright (c) 2000 - 2017 The Legion of the Bouncy Castle Inc. (https://www.bouncycastle.org)
[JSON License](http://json.org/license.html) | org.json # json # 20180813 | Copyright (c) 2002 JSON.org
[Apache License, Version 2](http://www.apache.org/licenses/LICENSE-2.0) | nc.com # ExponentialSmoothing # 1.0 | Copyright 2011 [Nishant Chandra](https://github.com/nchandra/ExponentialSmoothing)
[Eclipse Public License](http://www.eclipse.org/legal/epl-v10.html) | etherip.util.Hexdump | Derivative of single file. Copyright (c) 2012 Oak Ridge National Laboratory. Author: Kay Kasemir.
[Go License](http://golang.org/LICENSE) | com.google.re2j # re2j # 1.2 | Copyright (C) 2018 by The Go Authors

## Elm/JS Dependencies

License | Module | Attribution
--- | --- | ---
[BSD 3-Clause License](https://raw.githubusercontent.com/elm-tools/parser-primitives/master/LICENSE)  |  "elm-tools/parser-primitives": "1.0.0" | Copyright (c) 2017-present, Evan Czaplicki.
[MIT License](https://raw.githubusercontent.com/krisajenkins/elm-exts/master/LICENSE) |    "krisajenkins/elm-exts": "26.5.0" | Copyright (c) 2017 Kris Andrew Jenkins
[BSD 3-Clause License](https://github.com/elm-lang/navigation/blob/master/LICENSE) | "elm-lang/navigation": "2.1.0" | Copyright (c) 2016, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/virtual-dom/blob/master/LICENSE) |    "elm-lang/virtual-dom": "2.0.4" | Copyright (c) 2016-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/mouse/blob/master/LICENSE) |    "elm-lang/mouse": "1.0.1" | Copyright (c) 2016-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/evancz/url-parser/blob/master/LICENSE) |    "evancz/url-parser": "2.0.1" | Copyright (c) 2016, Evan Czaplicki
[BSD 3-Clause License](https://github.com/NoRedInk/elm-simple-fuzzy/blob/master/LICENSE) |     "NoRedInk/elm-simple-fuzzy": "1.0.1" | Copyright (c) 2015, NoRedInk
[BSD 3-Clause License](https://github.com/evancz/elm-markdown/blob/master/LICENSE) |     "evancz/elm-markdown": "3.0.2" | Copyright (c) 2014, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/dom/blob/master/LICENSE) |     "elm-lang/dom": "1.1.1" | Copyright (c) 2016, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/html/blob/master/LICENSE) |     "elm-lang/html": "2.0.0" | Copyright (c) 2014-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/keyboard/blob/master/LICENSE) |     "elm-lang/keyboard": "1.0.1" | Copyright (c) 2016-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-tools/parser/blob/master/LICENSE) |     "elm-tools/parser": "2.0.1" | Copyright (c) 2017-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/http/blob/master/LICENSE) |     "elm-lang/http": "1.0.0" | Copyright (c) 2016-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/rluiten/elm-date-extra/blob/master/LICENSE) |     "rluiten/elm-date-extra": "8.7.0" | Copyright (c) 2015-2017, Robin Luiten www.github.com/rluiten
[MIT License](https://github.com/lukewestby/elm-http-builder/blob/master/LICENSE) |     "lukewestby/elm-http-builder": "4.0.0" | Copyright (c) 2016 Luke Westby
[MIT License](http://www.opensource.org/licenses/mit-license.php) |     "sporto/erl": "11.1.1" | Copyright (c) 2017 Sebastian Porto
[BSD 3-Clause License](https://github.com/elm-lang/trampoline/blob/master/LICENSE) |    "elm-lang/trampoline": "1.0.1" | Copyright (c) 2016, Evan Czaplicki
[BSD 3-Clause License](https://github.com/elm-lang/core/blob/master/LICENSE) |     "elm-lang/core": "5.1.1" | Copyright (c) 2014-present, Evan Czaplicki
[BSD 3-Clause License](https://github.com/rtfeldman/elm-css/blob/master/LICENSE) |     "rtfeldman/elm-css": "11.1.0" | Copyright (c) 2015, Richard Feldman
[BSD 3-Clause License](https://github.com/rtfeldman/elm-css-helpers/blob/master/LICENSE) |     "rtfeldman/elm-css-helpers": "2.1.0" | Copyright (c) 2015, Richard Feldman
[BSD 3-Clause License](https://github.com/elm-lang/animation-frame/blob/master/LICENSE) |     "elm-lang/animation-frame": "1.0.1" | Copyright (c) 2016, Evan Czaplicki
[Facebook License](https://raw.githubusercontent.com/graphql/graphiql/master/LICENSE) |     "graphql/graphiql": "0.11.10" | Copyright (c) 2015, Facebook, Inc. All rights reserved.
[MIT License](https://github.com/facebook/react/blob/master/LICENSE) | "facebook/react": "15.4.2" | Copyright (c) 2013-present, Facebook, Inc.
[MIT License](https://github.com/facebook/react/blob/master/LICENSE) | "facebook/react-dom": "15.4.2" | Copyright (c) 2013-present, Facebook, Inc.
[MIT License](https://github.com/codemirror/CodeMirror/blob/master/LICENSE) | "codemirror": "5.34" | Copyright (C) 2017 by Marijn Haverbeke <marijnh@gmail.com> and others
[MIT License](https://github.com/kazzkiq/balloon.css/blob/master/LICENSE) | "balloon.css": "0.5.0" | Copyright (c) 2016 Claudio Holanda
[MIT License](https://github.com/dillonkearns/graphqelm/blob/master/LICENSE) | "dillonkearns/graphqelm": "10.0.0" | Copyright (c) 2017, Dillon Kearns
[MIT License](https://github.com/elm-community/elm-time/blob/master/LICENSE) | "elm-community/elm-time": "1.0.14" | Copyright (c) 2016, Bogdan Paul Popa
[MIT License](https://github.com/mgold/elm-date-format/blob/master/LICENSE) | mgold/elm-date-format": "1.4.1" | Copyright (c) 2014, Max Goldstein
[BSD 3-Clause License](https://github.com/myrho/elm-round/blob/master/LICENSE) | myrho/elm-round: "1.0.0" | Copyright (c) 2018, Matthias Rella
[BSD 3-Clause License](https://github.com/supermario/elm-countries) | supermario/elm-countries "1.0.2" | Copyright (c) 2018, Mario Rogic
[MIT License](https://github.com/alpacaaa/elm-date-distance/blob/1.1.0/LICENSE) | "alpacaaa/elm-date-distance": "1.1.0" | Copyright (c) 2017 Marco Sampellegrini
[MIT License](https://github.com/jamesmacaulay/elm-graphql/blob/master/LICENSE) | "jamesmacaulay/elm-graphql": "1.8.0" | Copyright 2017 James MacAulay
[MIT License](http://www.opensource.org/licenses/mit-license.php) | Moment.js | Tim Wood, Iskren Chernev, Moment.js contributors
[BSD 3-Clause License](https://github.com/isagalaev/highlight.js/blob/master/LICENSE) | Highlight.js | Copyright (c) 2006, Ivan Sagalaev (theme by Louis Barranqueiro)
[BSD 3-Clause License](https://github.com/webcomponents/webcomponentsjs/blob/master/LICENSE.md) | @webcomponents/webcomponentsjs | Copyright (c) 2015 The Polymer Authors. All rights reserved.
[BSD 3-Clause License](https://github.com/xarvh/elm-onclickoutside/blob/master/LICENSE) | xarvh/elm-onclickoutside | Copyright (c) 2017 Francesco Orsenigo.

## Other Resources

License | Module | Attribution
--- | --- | ---
[Apache License Version 2.0](https://github.com/google/material-design-icons/blob/master/LICENSE) | Material Design Icons | Copyright (C) Google
[Apache License Version 2.0](https://github.com/google/material-design-icons/blob/master/LICENSE) | Open Sans | Copyright (C) Google
