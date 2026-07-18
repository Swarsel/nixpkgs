{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bison,
  curl,
  docbook_xsl,
  eventlog,
  flex,
  glib,
  gperf,
  grpc,
  hiredis,
  json_c,
  libcap,
  libesmtp,
  libivykis,
  libnet,
  libuuid,
  libxslt,
  mongoc,
  openssl,
  paho-mqtt-c,
  pcre2,
  perl,
  pkg-config,
  protobuf,
  protobufc,
  python3,
  python3Packages,
  rabbitmq-c,
  rdkafka,
  riemann_c_client,
  systemd,
  which,
  withGrpc ? true,
}:
let
  python-deps =
    ps: with ps; [
      boto3
      botocore
      cachetools
      certifi
      charset-normalizer
      google-auth
      idna
      kubernetes
      oauthlib
      pyasn1
      pyasn1-modules
      python-dateutil
      pyyaml
      requests
      requests-oauthlib
      rsa
      six
      urllib3
      websocket-client
      ply
    ];
  py = python3.withPackages python-deps;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "syslog-ng";
  version = "4.11.0";

  src = fetchFromGitHub {
    owner = "syslog-ng";
    repo = "syslog-ng";
    tag = "syslog-ng-${finalAttrs.version}";
    hash = "sha256-7t1Q3qaPMp36siQALmeB27G6hfsql+kepERGB0yPsVU=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
    which
    bison
    flex
    libxslt
    perl
    gperf
    python3Packages.setuptools
  ];

  buildInputs = [
    libcap
    curl
    openssl
    eventlog
    glib
    py
    systemd
    riemann_c_client
    protobufc
    libnet
    json_c
    libuuid
    libivykis
    mongoc
    rabbitmq-c
    libesmtp
    pcre2
    paho-mqtt-c
    hiredis
    rdkafka
  ]
  ++ (lib.optionals withGrpc [
    protobuf
    grpc
  ]);

  configureFlags = [
    "--enable-manpages"
    "--with-docbook=${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl"
    "--enable-dynamic-linking"
    "--enable-systemd"
    "--enable-smtp"
    "--with-python-packages=none"
    "--with-hiredis=system"
    "--with-ivykis=system"
    "--with-librabbitmq-client=system"
    "--with-mongoc=system"
    "--with-jsonc=system"
    "--with-systemd-journal=system"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--without-compile-date"
  ]
  ++ (lib.optionals withGrpc [ "--enable-grpc" ]);

  enableParallelBuilding = true;

  meta = {
    description = "Next-generation syslogd with advanced networking and filtering capabilities";
    homepage = "https://www.syslog-ng.com";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ vifino ];
    platforms = lib.platforms.linux;
  };
})
