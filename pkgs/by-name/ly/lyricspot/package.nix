{
  lib,
  fetchFromGitHub,
  makeWrapper,
  playerctl,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lyricspot";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "vlensys";
    repo = "lyricspot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qDXTcTlpMWW7vAQuOFBEnM26DvIdy/fvkGTL/TdDa2A=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp lyricspot.py $out/bin/lyricspot
    chmod +x $out/bin/lyricspot
    wrapProgram $out/bin/lyricspot \
      --prefix PATH ":" ${
        lib.makeBinPath [
          python3
          playerctl
        ]
      }
  '';

  __structuredAttrs = true;

  meta = {
    description = "Good old live synced lyrics in your terminal";
    homepage = "https://github.com/vlensys/lyricspot";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      yarn
    ];

    platforms = lib.platforms.unix;
    mainProgram = "lyricspot";
  };
})
