{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  curl,
  fetchMavenArtifact,
  fetchpatch,
  git,
  jdk8,
  makeWrapper,
  net-tools,
  python3,
}:

let
  jdk = jdk8;
  jre = jdk8.jre;
  artifacts = {
    apache = [
      (fetchMavenArtifact {
        version = "3.6.1";
        artifactId = "commons-math3";
        groupId = "org.apache.commons";
        hash = "sha256-HlbXsFjSi2Wr0la4RY44hbZ0wdWI+kPNfRy7nH7yswg=";
      })
    ];

    guava = [
      (fetchMavenArtifact {
        version = "18.0";
        artifactId = "guava";
        groupId = "com.google.guava";
        hash = "sha256-1mT7/APS5c6cqypE+wHx0L+d/r7MwaRzsfnqMfefb5k=";
      })
    ];

    gwt = [
      (fetchMavenArtifact {
        version = "2.6.1";
        artifactId = "gwt-dev";
        groupId = "com.google.gwt";
        hash = "sha256-iS8VpnMPuxE9L9hkTJVtW5Tqgw2TIYei47zRvkdoK0o=";
      })
      (fetchMavenArtifact {
        version = "2.6.1";
        artifactId = "gwt-user";
        groupId = "com.google.gwt";
        hash = "sha256-3IlJ+b6C0Gmuh7aAFg9+ldgvZCdfJmTB8qcdC4HZC9g=";
      })
      (fetchMavenArtifact {
        version = "1.0.0";
        artifactId = "opentsdb-gwt-theme";
        groupId = "net.opentsdb";
        hash = "sha256-JJsjcRlQmIrwpOtMweH12e/Ut5NG8R50VPiOAMMGEdc=";
      })
    ];

    hamcrest = [
      (fetchMavenArtifact {
        version = "1.3";
        artifactId = "hamcrest-core";
        groupId = "org.hamcrest";
        hash = "sha256-Zv3vkelzk0jfeglqo4SlaF9Oh1WEzOiThqekclHE2Ok=";
        url = "mirror://maven/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar";
      })
    ];

    hbase = [
      (fetchMavenArtifact {
        version = "1.8.2";
        artifactId = "asynchbase";
        groupId = "org.hbase";
        hash = "sha256-D7mKprHMW23dE0SzdNsagv3Hp2G5HUN7sKfs1nVzQF4=";
      })
    ];

    jackson = [
      (fetchMavenArtifact {
        version = "2.14.1";
        artifactId = "jackson-annotations";
        groupId = "com.fasterxml.jackson.core";
        hash = "sha256-0lW0uGP/jscUqPlvpVw0Yh1D27grgtP1dHZJakwJ4ec=";
      })
      (fetchMavenArtifact {
        version = "2.14.1";
        artifactId = "jackson-core";
        groupId = "com.fasterxml.jackson.core";
        hash = "sha256-ARQYfilrNMkxwb+eWoQVK2K/q30YL1Yj85gtwto15SY=";
      })
      (fetchMavenArtifact {
        version = "2.14.1";
        artifactId = "jackson-databind";
        groupId = "com.fasterxml.jackson.core";
        hash = "sha256-QjoMgG3ks/petKKGmDBeOjd3xzHhvPobLzo3YMe253M=";
      })
    ];

    javacc = [
      (fetchMavenArtifact {
        version = "6.1.2";
        artifactId = "javacc";
        groupId = "net.java.dev.javacc";
        hash = "sha256-7Qxclglhz+tDE4LPAVKCewEVZ0fbN5LRv5PoHjLCBKs=";
      })
    ];

    javassist = [
      (fetchMavenArtifact {
        version = "3.21.0-GA";
        artifactId = "javassist";
        groupId = "org.javassist";
        hash = "sha256-eqWeAx+UGYSvB9rMbKhebcm9OkhemqJJTLwDTvoSJdA=";
      })
    ];

    jexl = [
      (fetchMavenArtifact {
        version = "1.2";
        artifactId = "commons-logging";
        groupId = "commons-logging";
        hash = "sha256-2t3qHqC+D1aXirMAa4rJKDSv7vvZt+TmMW/KV98PpjY=";
      })
      (fetchMavenArtifact {
        version = "2.1.1";
        artifactId = "commons-jexl";
        groupId = "org.apache.commons";
        hash = "sha256-A8mp+uXaeM5SwL8kRnzDc1W34jGW3/SDniwP8BigEwY=";
      })
    ];

    jgrapht = [
      (fetchMavenArtifact {
        version = "0.9.1";
        artifactId = "jgrapht-core";
        groupId = "org.jgrapht";
        hash = "sha256-5u8cEVaJ7aCBQrhtUkYg2mQ7bp8BNAUletB/QtxcaXg=";
      })
    ];

    junit = [
      (fetchMavenArtifact {
        version = "4.11";
        artifactId = "junit";
        groupId = "junit";
        hash = "sha256-kKjhYD7spI5+h586+8lWBxUyKYXzmidPb2BwtD+dBv4=";
      })
    ];

    kryo = [
      (fetchMavenArtifact {
        version = "4.0";
        artifactId = "asm";
        groupId = "org.ow2.asm";
        hash = "sha256-+y3ekCCke7AkxD2d4KlOc6vveTvwjwE1TMl8stLiqVc=";
      })
      (fetchMavenArtifact {
        version = "2.21.1";
        artifactId = "kryo";
        groupId = "com.esotericsoftware.kryo";
        hash = "sha256-adEG73euU3sZBp9WUQNLZBN6Y3UAZXTAxjsuvDuy7q4=";
      })
      (fetchMavenArtifact {
        version = "1.2";
        artifactId = "minlog";
        groupId = "com.esotericsoftware.minlog";
        hash = "sha256-pnjLGqj10D2QHJksdXQYQdmKm8PVXa0C6E1lMVxOYPI=";
      })
      (fetchMavenArtifact {
        version = "1.07";
        artifactId = "reflectasm";
        classifier = "shaded";
        groupId = "com.esotericsoftware.reflectasm";
        hash = "sha256-CKcOrbSydO2u/BGUwfdXBiGlGwqaoDaqFdzbe5J+fHY=";
      })
    ];

    logback = [
      (fetchMavenArtifact {
        version = "1.3.4";
        artifactId = "logback-classic";
        groupId = "ch.qos.logback";
        hash = "sha256-uGal2myLeOFVxn/M11YoYNC1/Hdric2WjC8/Ljf8OgI=";
      })
      (fetchMavenArtifact {
        version = "1.3.4";
        artifactId = "logback-core";
        groupId = "ch.qos.logback";
        hash = "sha256-R0CgmLtEOnRFVN093wYsaCKHspQGZ1TikuE0bIv1zt0=";
      })
    ];

    mockito = [
      (fetchMavenArtifact {
        version = "1.9.5";
        artifactId = "mockito-core";
        groupId = "org.mockito";
        hash = "sha256-+XSDuglEufoTOqKWOHZN2+rbUew9vAIHTFj6LK7NB/o=";
      })
    ];

    netty = [
      (fetchMavenArtifact {
        version = "3.10.6.Final";
        artifactId = "netty";
        groupId = "io.netty";
        hash = "sha256-h2ilD749k6iNjmAA6l1o4w9Q3JFbN2TDxYcPcMT7O0k=";
      })
    ];

    objenesis = [
      (fetchMavenArtifact {
        version = "1.3";
        artifactId = "objenesis";
        groupId = "org.objenesis";
        hash = "sha256-3U7z0wkQY6T+xXjLsrvmwfkhwACRuimT3Nmv0l/5REo=";
      })
    ];

    powermock = [
      (fetchMavenArtifact {
        version = "1.5.4";
        artifactId = "powermock-mockito-release-full";
        classifier = "full";
        groupId = "org.powermock";
        hash = "sha256-GWXaFG/ZtPlc7uKrghQHNAPzEu2k5VGYCYTXIlbylb4=";
      })
    ];

    protobuf = [
      (fetchMavenArtifact {
        version = "2.5.0";
        artifactId = "protobuf-java";
        groupId = "com.google.protobuf";
        hash = "sha256-4MHGRXXABWAXJefGoCzr+eEoXoiPdWsqHXP/qNclzHQ=";
      })
    ];

    slf4j = [
      (fetchMavenArtifact {
        version = "2.0.6";
        artifactId = "log4j-over-slf4j";
        groupId = "org.slf4j";
        hash = "sha256-QHMpiJioL0KeHr2iNaMUc7G0jDR94ShnNbtnkiUm6uQ=";
      })
      (fetchMavenArtifact {
        version = "2.0.6";
        artifactId = "slf4j-api";
        groupId = "org.slf4j";
        hash = "sha256-LyqS1BCyaBOdfWO3XtJeIZlc/kEAwZvyNXfP28gHe9o=";
      })
    ];

    suasync = [
      (fetchMavenArtifact {
        version = "1.4.0";
        artifactId = "async";
        groupId = "com.stumbleupon";
        hash = "sha256-FJ1HH68JOkjNtkShjLTJ8K4NO/A/qu88ap7J7SEndrM=";
      })
    ];

    validation-api = [
      (fetchMavenArtifact {
        version = "1.0.0.GA";
        artifactId = "validation-api";
        groupId = "javax.validation";
        hash = "sha256-5FnzE+vG2ySD+M6q05rwcIY2G0dPqS5A9ELo3l2Yldw=";
      })
      (fetchMavenArtifact {
        version = "1.0.0.GA";
        artifactId = "validation-api";
        classifier = "sources";
        groupId = "javax.validation";
        hash = "sha256-o5TVKpt/4rsU8HGNKzyDCP/o836RGVYBI5jVXJ+fm1Q=";
      })
    ];

    zookeeper = [
      (fetchMavenArtifact {
        version = "3.4.6";
        artifactId = "zookeeper";
        groupId = "org.apache.zookeeper";
        hash = "sha256-ijdaHvmMvA4fbp39DZbZFLdNN60AtL+Bvrd/qPNNM64=";
      })
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "opentsdb";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "OpenTSDB";
    repo = "opentsdb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-899m1H0UCLsI/bnSrNFnnny4MxSw3XBzf7rgDuEajDs=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-4LpR4O8mNiJZQ7PUmAzFdkZAaF8i9/ZM5NhQ+8AJgSw=";
      name = "bump-deps.0.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/2f4bbfba2f9a32f9295123e8b90adba022c11ece.patch";
    })
    (fetchpatch {
      hash = "sha256-LZHqDOhwO/Gfgu870hJ6/uxnmigv7RP8OFe2a7Ug5SM=";
      name = "bump-deps.1.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/8c6a86ddbc367c7e4e2877973b70f77c105c6158.patch";
    })
    (fetchpatch {
      hash = "sha256-2VjI9EkirKj4h7xhUtWdnKxJG0Noz3Hk5njm3pYEU1g=";
      name = "bump-deps.2.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/9b62442ba5c006376f57ef250fb7debe1047c3bf.patch";
    })
    (fetchpatch {
      hash = "sha256-GgoRZUGdKthK+ZwMpgSQQ4V2oHyqi8SwWGZT571gltQ=";
      name = "CVE-2023-25826.prerequisite.0.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/a82a4f85f0fc1af554a104f28cc495451b26b1f6.patch";
    })
    (fetchpatch {
      hash = "sha256-pXo6U7d4iy2squAiFvV2iDAQcNDdrl0pIOQEXfkJ3a8=";
      name = "CVE-2023-25826.prerequisite.1.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/22b27ea30a859a6dbdcd65fcdf61190d46e1b677.patch";
    })
    (fetchpatch {
      hash = "sha256-88gIOhAhLCQC/UesIdYtjf0UgKNfnO0W2icyoMmiC3U=";
      name = "CVE-2023-25826.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/07c4641471c6f5c2ab5aab615969e97211eb50d9.patch";
    })
    (fetchpatch {
      hash = "sha256-FJHUiEmGhBIHoyOwNZtUWA36ENbrqDkUT8HfccmMSe8=";
      name = "CVE-2023-25827.patch";
      url = "https://github.com/OpenTSDB/opentsdb/commit/fa88d3e4b5369f9fb73da384fab0b23e246309ba.patch";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    makeWrapper
  ];

  buildInputs = [
    curl
    jdk
    net-tools
    python3
    git
  ];

  preConfigure = ''
    chmod +x build-aux/fetchdep.sh.in
    patchShebangs ./build-aux/
    ./bootstrap
  '';

  preBuild = lib.concatStrings (
    lib.mapAttrsToList (
      dir:
      lib.concatMapStrings (artifact: ''
        cp ${artifact}/share/java/* third_party/${dir}
      '')
    ) artifacts
  );

  postInstall = ''
    wrapProgram $out/bin/tsdb \
      --set JAVA_HOME "${jre}" \
      --set JAVA "${jre}/bin/java"
  '';

  meta = {
    description = "Time series database with millisecond precision";
    homepage = "http://opentsdb.net";
    license = lib.licenses.lgpl21Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # maven dependencies
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tsdb";
  };
})
