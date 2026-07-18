{
  lib,
  stdenv,
  fetchurl,
  libressl,
  privsepPath ? "/var/empty",
  privsepUser ? "ntp",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openntpd";
  version = "6.8p1";

  src = fetchurl {
    url = "mirror://openbsd/OpenNTPD/openntpd-${finalAttrs.version}.tar.gz";
    sha256 = "0ijsylc7a4jlpxsqa0jq1w1c7333id8pcakzl7a5749ria1xp0l5";
  };

  postPatch = ''
    sed -i '20i#include <sys/cdefs.h>' src/ntpd.h
    sed -i '19i#include <sys/cdefs.h>' src/log.c
  '';

  buildInputs = [ libressl ];

  configureFlags = [
    "--with-privsep-path=${privsepPath}"
    "--with-privsep-user=${privsepUser}"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-cacert=/etc/ssl/certs/ca-certificates.crt"
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  meta = {
    description = "OpenBSD NTP daemon (Debian port)";
    homepage = "https://www.openntpd.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
  };
})
