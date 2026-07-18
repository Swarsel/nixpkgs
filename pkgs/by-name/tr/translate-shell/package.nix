{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  fribidi,
  gawk,
  groff,
  hexdump,
  makeWrapper,
  ncurses,
  rlwrap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "translate-shell";
  version = "0.9.7.1";

  src = fetchFromGitHub {
    owner = "soimort";
    repo = "translate-shell";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ILXE8cSrivYqMruE+xtNIInLdwdRfMX5dneY9Nn12Uk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/trans \
      --prefix PATH : ${
        lib.makeBinPath [
          gawk
          curl
          ncurses
          rlwrap
          groff
          fribidi
          hexdump
        ]
      }
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Command-line translator using Google Translate, Bing Translator, Yandex.Translate, and Apertium";
    homepage = "https://www.soimort.org/translate-shell";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.unix;
    mainProgram = "trans";
  };
})
