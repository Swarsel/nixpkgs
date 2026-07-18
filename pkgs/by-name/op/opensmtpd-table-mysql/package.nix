{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libmysqlclient,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opensmtpd-table-mysql";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "OpenSMTPD";
    repo = "table-mysql";
    tag = finalAttrs.version;
    hash = "sha256-0N1fuYJvJKAoOJMH2bX0pdvAqb26w/6JSuv6ycnRZHU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libmysqlclient
  ];

  buildInputs = [
    libmysqlclient
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-path-socket=/run"
    "--with-path-pidfile=/run"
  ];

  preConfigure = ''
    sh bootstrap
  '';

  meta = {
    description = "MySQL or MariaDB tables for the OpenSMTPD mail server";
    homepage = "https://www.opensmtpd.org/";
    changelog = "https://github.com/OpenSMTPD/table-mysql/releases/tag/${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      pks
    ];

    platforms = lib.platforms.linux;
  };
})
