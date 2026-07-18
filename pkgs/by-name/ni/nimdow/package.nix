{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  nixosTests,
  testers,
}:

buildNimPackage (finalAttrs: {
  pname = "nimdow";
  version = "0.7.41";

  src = fetchFromGitHub {
    owner = "avahe-kellenberger";
    repo = "nimdow";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oosoiJVlP3XyUeardoyRFladAIKdH3PQvWcNo5XnnOI=";
  };

  postPatch = ''
    substituteInPlace src/nimdowpkg/config/configloader.nim --replace "/usr/share/nimdow" "$out/share/nimdow"
  '';

  postInstall = ''
    install -D config.default.toml $out/share/nimdow/config.default.toml
    install -D nimdow.desktop $out/share/applications/nimdow.desktop
  '';

  lockFile = ./lock.json;

  nimFlags = [
    "--deepcopy:on"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = finalAttrs.finalPackage;
    };

    nimdow = nixosTests.nimdow;
  };

  meta =

    finalAttrs.src.meta // {
      description = "Nim based tiling window manager";
      license = [ lib.licenses.gpl2 ];
      maintainers = [ lib.maintainers.marcusramberg ];
      platforms = lib.platforms.linux;
      mainProgram = "nimdow";
    };
})
