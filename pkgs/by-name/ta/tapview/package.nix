{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tapview";
  version = "1.15";

  src = fetchFromGitLab {
    owner = "esr";
    repo = "tapview";
    tag = finalAttrs.version;
    hash = "sha256-6v+CxNjj3gPE3wmhit6e5OuhkjVACFv/4QAbFDCySGc=";
  };

  nativeBuildInputs = [ asciidoctor ];
  makeFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Minimalist pure consumer for TAP (Test Anything Protocol)";
    homepage = "https://gitlab.com/esr/tapview";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ pamplemousse ];
    platforms = lib.platforms.all;
    mainProgram = "tapview";
  };
})
