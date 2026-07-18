{
  lib,
  stdenv,
  fetchurl,
  bash,
  makeWrapper,
  nixosTests,
  suitesparse,
  temurin-jre-bin-17,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "photonvision";
  version = "2025.2.1";

  src =
    {
      "aarch64-linux" = fetchurl {
        hash = "sha256-YG9wyh+MCsv/RBdiFvgrF6Fw/6AnN7OEi4ofkMptfT0=";
        url = "https://github.com/PhotonVision/photonvision/releases/download/v${finalAttrs.version}/photonvision-v${finalAttrs.version}-linuxarm64.jar";
      };

      "x86_64-linux" = fetchurl {
        hash = "sha256-yEb6GCt29DjZNDsIqDvF/AiCw3QVMxUFKQM22OlMl7Q=";
        url = "https://github.com/PhotonVision/photonvision/releases/download/v${finalAttrs.version}/photonvision-v${finalAttrs.version}-linuxx64.jar";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D $src $out/lib/photonvision.jar

    makeWrapper ${temurin-jre-bin-17}/bin/java $out/bin/photonvision \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          stdenv.cc.cc
          suitesparse
        ]
      } \
      --prefix PATH : ${
        lib.makeBinPath [
          temurin-jre-bin-17
          bash.out
        ]
      } \
      --add-flags "-jar $out/lib/photonvision.jar"

    runHook postInstall
  '';

  dontUnpack = true;

  passthru.tests = {
    starts-web-server = nixosTests.photonvision;
  };

  meta = {
    description = "Free, fast, and easy-to-use computer vision solution for the FIRST Robotics Competition";
    homepage = "https://photonvision.org/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ max-niederman ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "photonvision";
  };
})
