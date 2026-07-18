{
  lib,
  stdenv,
  fetchurl,
  c-ares,
  libevent,
  nixosTests,
  openssl,
  pandoc,
  pkg-config,
  python3,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pgbouncer";
  version = "1.25.2";

  src = fetchurl {
    url = "https://www.pgbouncer.org/downloads/files/${finalAttrs.version}/pgbouncer-${finalAttrs.version}.tar.gz";
    hash = "sha256-kkrTURP9CnHI4tvoW10DRFUy4rezep+KSJg77qI4szI=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
    pandoc
  ];

  buildInputs = [
    libevent
    openssl
    c-ares
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux systemd;

  configureFlags = lib.optional stdenv.hostPlatform.isLinux "--with-systemd";
  enableParallelBuilding = true;

  passthru.tests = {
    pgbouncer = nixosTests.pgbouncer;
  };

  meta = {
    description = "Lightweight connection pooler for PostgreSQL";
    homepage = "https://www.pgbouncer.org/";

    changelog = "https://github.com/pgbouncer/pgbouncer/releases/tag/pgbouncer_${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }";

    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ _1000101 ];
    platforms = lib.platforms.all;
    mainProgram = "pgbouncer";
  };
})
