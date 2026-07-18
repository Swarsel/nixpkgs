{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchYarnDeps,
  go-rice,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
}:
let
  version = "0.93.0";

  src = fetchFromGitHub {
    owner = "statping-ng";
    repo = "statping-ng";
    tag = "v${version}";
    hash = "sha256-VVM3Jyahs0OQuHiF/r+U9vq9TBOFOtuTzBurAhR1Dhc=";
  };

  frontend = stdenv.mkDerivation {
    inherit version;
    pname = "statping-ng-frontend";
    src = "${src}/frontend";

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
      yarnBuildHook
    ];

    preBuild = ''
      export NODE_OPTIONS=--openssl-legacy-provider
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -rt "$out" dist/* src/assets/scss public/robots.txt

      runHook postInstall
    '';

    yarnOfflineCache = fetchYarnDeps {
      hash = "sha256-e8GyKIJ0RopRliVMVrY8eEd6Qx/gTKbW3biPCSqbRrQ=";
      yarnLock = "${src}/frontend/yarn.lock";
    };
  };
in
buildGoModule rec {
  inherit version src;
  pname = "statping-ng";

  postPatch = ''
    ln -s "${frontend}" source/dist
  '';

  nativeBuildInputs = [
    go-rice
  ];

  vendorHash = "sha256-ZcNOI5/Fs7/U8/re89YpJ3qlMaQStLrrNHXiHuBQwQk=";

  preBuild = ''
    (cd source && rice embed-go)
  '';

  doCheck = false;

  postInstall = ''
    mv $out/bin/cmd $out/bin/statping-ng
    $out/bin/statping-ng version | grep ${version} > /dev/null
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.VERSION=${version}"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/"
  ];

  tags = [
    "netgo"
    "ousergo"
  ];

  meta = {
    description = "Status Page for monitoring your websites and applications with beautiful graphs, analytics, and plugins";
    homepage = "https://github.com/statping-ng/statping-ng";
    changelog = "https://github.com/statping-ng/statping-ng/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      FKouhai
    ];

    platforms = lib.platforms.linux;
    mainProgram = "statping-ng";
  };
}
