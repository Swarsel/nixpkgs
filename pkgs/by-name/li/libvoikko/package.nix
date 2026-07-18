{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  hfst-ospell,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvoikko";
  version = "4.3.3";

  src = fetchFromGitHub {
    owner = "voikko";
    repo = "corevoikko";
    tag = "rel-libvoikko-${finalAttrs.version}";
    hash = "sha256-iWBIXAJKzjSP5mEBSfI+uZl0b2wRsjrYfdX2cHF/uuk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
  ];

  buildInputs = [
    hfst-ospell
  ];

  sourceRoot = "${finalAttrs.src.name}/libvoikko";

  meta = {
    description = "Finnish language processing library";
    homepage = "https://voikko.puimula.org/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ lurkki ];
    platforms = lib.platforms.unix;
  };
})
