{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg,
  mpv,
  yt-dlp,
}:

buildGoModule (finalAttrs: {
  pname = "invidtui";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "darkhz";
    repo = "invidtui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C465lzbZIh8LYDUHNa5u66nFteFsKAffilvy1Danfpg=";
  };

  postPatch = ''
    substituteInPlace cmd/flags.go \
      --replace "\"ffmpeg\"" "\"${lib.getBin ffmpeg}/bin/ffmpeg\"" \
      --replace "\"mpv\"" "\"${lib.getBin mpv}/bin/mpv\"" \
      --replace "\"yt-dlp\"" "\"${lib.getBin yt-dlp}/bin/yt-dlp\""
  '';

  vendorHash = "sha256-C7O2GJuEdO8geRPfHx1Sq6ZveDE/u65JBx/Egh3cnK4=";
  doCheck = true;

  meta = {
    description = "Invidious TUI client";
    homepage = "https://darkhz.github.io/invidtui/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rettetdemdativ ];
    mainProgram = "invidtui";
  };
})
