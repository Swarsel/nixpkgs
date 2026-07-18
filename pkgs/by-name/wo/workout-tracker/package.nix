{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  nix-update-script,
  nixosTests,
}:
let
  pname = "workout-tracker";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "jovandeginste";
    repo = "workout-tracker";
    tag = "v${version}";
    hash = "sha256-bSeZkUzcRrdH3jSagj842DoxKBf0ysNuINY/g+VWkl0=";
  };

  assets = buildNpmPackage {
    inherit version src;
    pname = "${pname}-assets";

    postPatch = ''
      cd frontend
    '';

    npmDepsHash = "sha256-vSFwCB5qbiHLiK0ns6YUj8yr3FjeNCqT8yvLRQzZycI=";

    installPhase = ''
      runHook preInstall
      cp -r ../assets "$out"
      runHook postInstall
    '';

    makeCacheWritable = true;
  };
in
buildGoModule {
  inherit pname version src;

  postPatch = ''
    rm -r assets
    ln -s ${assets} ./assets
  '';

  vendorHash = null;
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.buildTime=1970-01-01T00:00:00Z"
    "-X main.gitCommit=v${version}"
    "-X main.gitRef=v${version}"
    "-X main.gitRefName=v${version}"
  ];

  passthru.tests = {
    inherit (nixosTests) workout-tracker;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Workout tracking web application for personal use";
    homepage = "https://github.com/jovandeginste/workout-tracker";
    changelog = "https://github.com/jovandeginste/workout-tracker/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bhankas
      sikmir
    ];

    mainProgram = "workout-tracker";
  };
}
