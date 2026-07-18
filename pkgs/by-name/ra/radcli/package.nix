{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  doxygen,
  gettext,
  gnutls,
  libabigail,
  nettle,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radcli";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "radcli";
    repo = "radcli";
    tag = finalAttrs.version;
    hash = "sha256-8lumfZXIYeFTjtakj1s+gxoVaDMzoKlQMYgpq4BIc+U=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    doxygen
    gettext
    gnutls
    libabigail
    nettle
  ];

  postUnpack = ''
    touch ${finalAttrs.src.name}/config.rpath
  '';

  meta = {
    description = "Simple RADIUS client library";
    homepage = "https://github.com/radcli/radcli";
    changelog = "https://github.com/radcli/radcli/blob/${finalAttrs.version}/NEWS";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "radcli";
  };
})
