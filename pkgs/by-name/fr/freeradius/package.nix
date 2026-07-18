{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bsd-finger,
  collectd,
  curl,
  hiredis,
  json_c,
  libcap,
  libmemcached,
  libmysqlclient,
  libpcap,
  libpq,
  libyubikey,
  openldap,
  openssl,
  perl,
  sqlite,
  talloc,
  linkOpenssl ? true,
  withCap ? true,
  withCollectd ? false,
  withJson ? false,
  withLdap ? true,
  withMemcached ? false,
  withMysql ? false,
  withPcap ? true,
  withPostgresql ? false,
  withRedis ? false,
  withRest ? false,
  withSqlite ? true,
  withYubikey ? false,
}:

assert withRest -> withJson;

stdenv.mkDerivation rec {
  pname = "freeradius";
  version = "3.2.10";

  src = fetchFromGitHub {
    owner = "FreeRADIUS";
    repo = "freeradius-server";
    tag = "release_${lib.replaceStrings [ "." ] [ "_" ] version}";
    hash = "sha256-+pFV6dDnL7T5G309cLACa+/0vGppCEdk3ghOQhgSjTs=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  postPatch = ''
    substituteInPlace src/main/checkrad.in \
      --replace "/usr/bin/finger" "${bsd-finger}/bin/finger"
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    openssl
    talloc
    bsd-finger
    perl
  ]
  ++ lib.optional withCap libcap
  ++ lib.optional withCollectd collectd
  ++ lib.optional withJson json_c
  ++ lib.optional withLdap openldap
  ++ lib.optional withMemcached libmemcached
  ++ lib.optional withMysql libmysqlclient
  ++ lib.optional withPostgresql libpq
  ++ lib.optional withPcap libpcap
  ++ lib.optional withRedis hiredis
  ++ lib.optional withRest curl
  ++ lib.optional withSqlite sqlite
  ++ lib.optional withYubikey libyubikey;

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ]
  ++ lib.optional (!linkOpenssl) "--with-openssl=no";

  # By default, freeradius will generate Diffie-Hellman parameters and
  # self-signed TLS certificates during installation. We don't want
  # this, for several reasons:
  # - reproducibility (random generation)
  # - we don't want _anybody_ to use a cert where the private key is on our public binary cache!
  # - we don't want the certs to change each time the package is rebuilt
  # So let's avoid anything getting into our output.
  makeFlags = [ "LOCAL_CERT_FILES=" ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
    "INSTALL_CERT_FILES=" # see comment at makeFlags
  ];

  meta = {
    description = "Modular, high performance free RADIUS suite";
    homepage = "https://freeradius.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
  };
}
## TODO: include windbind optionally (via samba?)
## TODO: include oracle optionally
## TODO: include ykclient optionally
