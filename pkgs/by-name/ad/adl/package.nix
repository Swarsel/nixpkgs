{
  lib,
  fetchFromGitHub,
  animdl,
  frece,
  fzf,
  makeWrapper,
  mpv,
  perl,
  stdenvNoCC,
  trackma,
  ueberzug,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "adl";
  version = "3.2.8";

  src = fetchFromGitHub {
    owner = "RaitaroH";
    repo = "adl";
    rev = "a40f31454de856d9e9235d6216eaf8f4296111c4";
    hash = "sha256-Kg/iGyEdWJyoPn5lVqRCJX2eqdP1xwZqNU2RvTrhZko=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # https://github.com/RaitaroH/adl#requirements
  buildInputs = [
    animdl
    frece
    fzf
    mpv
    perl
    trackma
    ueberzug
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/adl $out/bin
    wrapProgram $out/bin/adl \
      --prefix PATH : ${lib.makeBinPath finalAttrs.buildInputs}
  '';

  dontBuild = true;

  meta = {
    description = "Popcorn anime scraper/downloader + trackma wrapper";
    homepage = "https://github.com/RaitaroH/adl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ weathercold ];
    platforms = lib.platforms.linux;
    mainProgram = "adl";
  };
})
