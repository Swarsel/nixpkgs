{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  nixosTests,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "adguardhome";
  version = "0.107.77";

  src = fetchFromGitHub {
    owner = "AdguardTeam";
    repo = "AdGuardHome";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CwM8Zi5FXNwb+5gdESoP31Ja1O6PrnOgFfJaT8Yc890=";
  };

  vendorHash = "sha256-D91mHBG78LOG1O5oVlaA3T8HWIISPeKMB06VpWuxxqo=";

  preBuild = ''
    cp -r ${finalAttrs.dashboard}/build/static build
  '';

  dashboard = buildNpmPackage {
    inherit (finalAttrs) src version;
    pname = "adguardhome-dashboard";

    postPatch = ''
      cd client
    '';

    npmDepsHash = "sha256-Yyv8dTKhZ9IlIW/x/57cl/+cpvjjycaFLSyOR0IiIPk=";

    postBuild = ''
      mkdir -p $out/build/
      cp -r ../build/static/ $out/build/
    '';

    npmBuildScript = "build-prod";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/AdguardTeam/AdGuardHome/internal/version.version=${finalAttrs.version}"
  ];

  passthru = {
    schema_version = 34;
    tests.adguardhome = nixosTests.adguardhome;

    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Network-wide ads & trackers blocking DNS server";
    homepage = "https://github.com/AdguardTeam/AdGuardHome";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      numkem
      iagoq
      rhoriguchi
      baksa
    ];

    mainProgram = "AdGuardHome";
  };
})
