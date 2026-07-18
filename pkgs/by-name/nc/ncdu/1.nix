{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncdu";
  version = "1.22";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/ncdu-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-CtbAltwE1RIFgRBHYMAbj06X1BkdbJ73llT6PGkaF2s=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Disk usage analyzer with an ncurses interface";
    homepage = "https://dev.yorhel.nl/ncdu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.all;
    mainProgram = "ncdu";
  };
})
