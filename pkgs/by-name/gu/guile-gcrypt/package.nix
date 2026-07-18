{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitea,
  guile,
  libgcrypt,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-gcrypt";
  version = "0.5.0";

  src = fetchFromGitea {
    owner = "cwebber";
    repo = "guile-gcrypt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YPzOKFwKxEbu4+tW1Pu6EeALArTUEfM/bSQPth5eBX4=";
    domain = "notabug.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    libgcrypt
    pkg-config
    texinfo
  ];

  buildInputs = [
    guile
  ];

  propagatedBuildInputs = [
    libgcrypt
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  doCheck = true;
  # In procedure bytevector-u8-ref: Argument 2 out of range
  dontStrip = stdenv.hostPlatform.isDarwin;

  meta = {
    description = "Bindings to Libgcrypt for GNU Guile";
    homepage = "https://notabug.org/cwebber/guile-gcrypt";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = guile.meta.platforms;
  };
})
