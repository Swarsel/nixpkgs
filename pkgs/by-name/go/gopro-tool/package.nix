{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg,
  jq,
  makeWrapper,
  nixosTests,
  vlc,
  x264,
  vlc' ? vlc.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ x264 ];
  }),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gopro-tool";
  version = "1.18";

  src = fetchFromGitHub {
    owner = "juchem";
    repo = "gopro-tool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nxsIMJjacxM0PtcopZCojz9gIa20TdKJiOyeUNHQA2o=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/gopro-tool $out/bin/gopro-tool
    chmod +x $out/bin/gopro-tool

    wrapProgram $out/bin/gopro-tool \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          vlc'
          jq
        ]
      }
  '';

  __structuredAttrs = true;

  passthru.tests = {
    inherit (nixosTests) gopro-tool;
  };

  meta = {
    description = "Tool to control GoPro webcam mode in Linux (requires v4l2loopback kernel module and a firewall rule)";
    homepage = "https://github.com/juchem/gopro-tool";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ZMon3y ];
    platforms = lib.platforms.linux;
  };
})
