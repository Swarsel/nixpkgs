{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
  gitUpdater,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "greed";
  version = "4.5";

  src = fetchFromGitLab {
    owner = "esr";
    repo = "greed";
    tag = finalAttrs.version;
    hash = "sha256-S2K6nn4WS1gOvhlYK/UH1hfA0pzij4w5SeP004WVZik=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "-lcurses" "-lncurses" \
      --replace-fail "/usr/games/lib/greed.hs" "/var/lib/greed/greed.hs"
  '';

  nativeBuildInputs = [
    asciidoctor
  ];

  buildInputs = [
    ncurses
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Game of Consumption";
    homepage = "http://www.catb.org/~esr/";
    changelog = "https://gitlab.com/esr/greed/-/blob/${finalAttrs.version}/NEWS.adoc?ref_type=tags";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "greed";
  };
})
