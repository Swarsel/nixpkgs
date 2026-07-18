{
  lib,
  stdenv,
  fetchurl,
  neon,
  openssl,
  pkg-config,
  readline,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cadaver";
  version = "0.28";

  src = fetchurl {
    url = "https://notroj.github.io/cadaver/cadaver-${finalAttrs.version}.tar.gz";
    hash = "sha256-M+OlS9VLHrMltIMWp8rMJAR8Uz74jm75i4jfu2DhJzQ=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    neon
    openssl
    zlib
    readline
  ];

  configureFlags = [
    "--with-ssl"
  ];

  meta = {
    description = "Command-line WebDAV client";
    homepage = "https://notroj.github.io/cadaver/";
    changelog = "https://github.com/notroj/cadaver/blob/${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ianwookim ];
    platforms = with lib.platforms; linux ++ freebsd ++ openbsd;
    mainProgram = "cadaver";
  };
})
