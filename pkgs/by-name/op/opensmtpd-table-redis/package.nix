{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  hiredis,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opensmtpd-table-redis";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "OpenSMTPD";
    repo = "table-redis";
    tag = finalAttrs.version;
    hash = "sha256-eS/jzran7/j3xrFuEqTLam0pokD/LBl4v2s/1ferCqk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [
    hiredis
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-path-socket=/run"
    "--with-path-pidfile=/run"
  ];

  env.NIX_CFLAGS_COMPILE = "-I${hiredis}/include/hiredis";

  preConfigure = ''
    sh bootstrap
  '';

  meta = {
    description = "Redis tables for the OpenSMTPD mail server";
    homepage = "https://www.opensmtpd.org/";
    changelog = "https://github.com/OpenSMTPD/table-redis/releases/tag/${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      pks
    ];

    platforms = lib.platforms.linux;
  };
})
