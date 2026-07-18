{
  lib,
  stdenv,
  fetchzip,
  libretls,
  libxcrypt,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pounce";
  version = "3.1";

  src = fetchzip {
    url = "https://git.causal.agency/pounce/snapshot/pounce-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-6PGiaU5sOwqO4V2PKJgIi3kI2jXsBOldEH51D7Sx9tg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libretls
    openssl
    libxcrypt
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  buildFlags = [ "all" ];

  meta = {
    description = "Simple multi-client TLS-only IRC bouncer";
    homepage = "https://code.causal.agency/june/pounce";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ edef ];
    platforms = lib.platforms.linux;
  };
})
