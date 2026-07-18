{
  lib,
  fetchFromGitHub,
  discord,
  makeWrapper,
  stdenvNoCC,
  discordAlias ? false,
}:

stdenvNoCC.mkDerivation rec {
  pname = "discocss";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mlvzk";
    repo = "discocss";
    rev = "v${version}";
    sha256 = "sha256-of7OMgbuwebnFmbefGD1/dOhyTX1Hy7TccnWSRCweW0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 discocss $out/bin/discocss
  ''
  + lib.optionalString discordAlias ''
    wrapProgram $out/bin/discocss --set DISCOCSS_DISCORD_BIN ${discord}/bin/Discord
    ln -s $out/bin/discocss $out/bin/Discord
    ln -s $out/bin/discocss $out/bin/discord
    mkdir -p $out/share
    ln -s ${discord}/share/* $out/share
  '';

  dontBuild = true;

  meta = {
    description = "Tiny Discord css-injector";
    homepage = "https://github.com/mlvzk/discocss";
    changelog = "https://github.com/mlvzk/discocss/releases/tag/v${version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ mlvzk ];
    platforms = lib.platforms.unix;
    mainProgram = "discocss";
  };
}
