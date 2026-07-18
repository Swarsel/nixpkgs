{
  lib,
  fetchFromGitHub,
  buildGoModule,
  cacert,
  fetchPnpmDeps,
  git,
  go,
  nixosTests,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pname = "homebox";
  version = "0.25.0";
  src = fetchFromGitHub {
    owner = "sysadminsmedia";
    repo = "homebox";
    tag = "v${version}";
    hash = "sha256-mAC7n8AjsSHzO+l0ILJhf4LPAuVZ5KIYO6mXftZpVbE=";
  };
in
buildGoModule {
  inherit pname version src;

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
    nodejs
  ];

  vendorHash = "sha256-FuZEGUduKZyTuW63z3rk8g1KE8wyx55xoNSvqbvF0PA=";
  env.CGO_ENABLED = 0;
  env.NUXT_TELEMETRY_DISABLED = 1;

  preBuild = ''
    pushd ../frontend

    pnpm build

    popd

    mkdir -p ./app/api/static/public
    cp -r ../frontend/.output/public/* ./app/api/static/public
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $GOPATH/bin/api $out/bin/

    runHook postInstall
  '';

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
    "-X main.version=${src.tag}"
    "-X main.commit=${src.tag}"
  ];

  modRoot = "backend";

  # the goModules derivation inherits our buildInputs and buildPhases
  # Since we do pnpm thing in those it fails if we don't explicitly remove them
  overrideModAttrs = _: {
    nativeBuildInputs = [
      go
      git
      cacert
    ];

    preBuild = "";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version;
    src = "${src}/frontend";
    fetcherVersion = 3;
    hash = "sha256-LrK0ijH8ahmDU4t9ckmIf1TJmybLLDRRHA67djUwRBk=";
    pnpm = pnpm_10;
  };

  pnpmRoot = "../frontend";

  tags = [
    "nodynamic"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) homebox;
    };
  };

  meta = {
    description = "Inventory and organization system built for the Home User";
    homepage = "https://homebox.software/";

    license = [
      lib.licenses.agpl3Only
      lib.licenses.mit
    ];

    maintainers = with lib.maintainers; [
      patrickdag
      tebriel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "api";
  };
}
