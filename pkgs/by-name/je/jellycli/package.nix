{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "jellycli";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "tryffel";
    repo = "jellycli";
    rev = "v${finalAttrs.version}";
    sha256 = "1awzcxnf175a794rhzbmqxxjss77mfa1yrr0wgdxaivrlkibxjys";
  };

  patches = [
    # Fixes log file path for tests.
    ./fix-test-dir.patch
  ];

  buildInputs = [ alsa-lib ];
  vendorHash = "sha256-3tmNZd1FH1D/1w4gRmaul2epKb70phSUAjUBCbPV3Ak=";

  meta = {
    description = "Jellyfin terminal client";

    longDescription = ''
      Terminal music player, works with Jellyfin (>= 10.6) , Emby (>= 4.4), and
      Subsonic comptabile servers (API >= 1.16), e.g., Navidrome.
    '';

    homepage = "https://github.com/tryffel/jellycli";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "jellycli";
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
