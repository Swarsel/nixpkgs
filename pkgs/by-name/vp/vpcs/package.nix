{
  lib,
  stdenv,
  fetchFromGitHub,
  testers,
  vpcs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vpcs";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "GNS3";
    repo = "vpcs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OKi4sC4fmKtkJkkpHZ6OfeIDaBafVrJXGXh1R6gLPFY=";
  };

  buildPhase = ''
    runHook preBuild

    MKOPT="CC=${stdenv.cc.targetPrefix}cc" ./mk.sh ${stdenv.buildPlatform.linuxArch}

    runHook postBuild
  '';

  postInstall = ''
    install -D -m555 vpcs $out/bin/vpcs
    install -D -m444 ../man/vpcs.1 $out/share/man/man1/vpcs.1
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  passthru.tests.version = testers.testVersion {
    command = "vpcs -v";
    package = vpcs;
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Simple virtual PC simulator";

    longDescription = ''
      The VPCS (Virtual PC Simulator) can simulate up to 9 PCs. You can
      ping/traceroute them, or ping/traceroute the other hosts/routers from the
      VPCS when you study the Cisco routers in the dynamips.
    '';

    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "vpcs";
  };
})
