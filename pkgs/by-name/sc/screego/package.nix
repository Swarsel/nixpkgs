{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchYarnDeps,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
}:
let

  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "screego";
    repo = "server";
    rev = "v${version}";
    hash = "sha256-xWy7aqpUznIYeBPqdpYdRMJxxfiPNa4JmjS3o5i3xxY=";
  };

  ui = stdenv.mkDerivation {
    inherit version;
    pname = "screego-ui";
    src = src + "/ui";

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      nodejs
    ];

    preConfigure = ''
      export HOME=$(mktemp -d)
    '';

    installPhase = ''
      cp -r build $out
    '';

    offlineCache = fetchYarnDeps {
      hash = "sha256-JPSbBUny5unUHVkaVGlHyA90IpT9ahcSmt9R1hxERRk=";
      yarnLock = "${src}/ui/yarn.lock";
    };

  };

in

buildGoModule rec {
  inherit src version;
  pname = "screego-server";

  postPatch = ''
    mkdir -p ./ui
    cp -r "${ui}" ./ui/build
  '';

  vendorHash = "sha256-vx7CpHUPQlLEQGxdswQJI1SrfSUwPlpNcb7Cq81ZOBQ=";

  postInstall = ''
    mv $out/bin/server $out/bin/screego
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
    "-X=main.commitHash=${src.rev}"
    "-X=main.mode=prod"
  ];

  meta = {
    description = "Screen sharing for developers";
    homepage = "https://screego.net";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ pinpox ];
    mainProgram = "screego";
  };
}
