{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchYarnDeps,
  go-bindata,
  nodejs_24,
  stdenvNoCC,
  versionCheckHook,
  yarnBuildHook,
  yarnConfigHook,
}:
let
  pname = "fleet";
  version = "4.82.2";
  src = fetchFromGitHub {
    owner = "fleetdm";
    repo = "fleet";
    tag = "fleet-v${version}";
    hash = "sha256-Cbn7phhaDcpYm3nV8nLb/2QVQl9mhsRfHa6GG59MNcA=";
  };

  frontend = stdenvNoCC.mkDerivation {
    inherit version src;
    pname = "${pname}-frontend";

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      nodejs_24
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/assets
      cp -r assets/* $out/assets/

      mkdir -p $out/frontend/templates
      cp frontend/templates/react.tmpl $out/frontend/templates/react.tmpl

      runHook postInstall
    '';

    NODE_ENV = "production";
    yarnBuildScript = "webpack";

    yarnOfflineCache = fetchYarnDeps {
      hash = "sha256-2gTV42OVgeH35rOrOgXiop+DGWtq2PpHqKY4mFblbAs=";
      yarnLock = src + "/yarn.lock";
    };
  };
in
buildGoModule (finalAttrs: {
  inherit pname version src;
  nativeBuildInputs = [ go-bindata ];
  vendorHash = "sha256-hgo+j2+gE0ArGRRvxC/0jcpv0Bp3hvBRO7Wl+9xl8io=";

  preBuild = ''
    cp -r ${frontend}/assets/* assets
    cp -r ${frontend}/frontend/templates/react.tmpl frontend/templates/react.tmpl

    go-bindata -pkg=bindata -tags full \
      -o=server/bindata/generated.go \
      frontend/templates/ assets/... server/mail/templates
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-X github.com/fleetdm/fleet/v4/server/version.appName=fleet"
    "-X github.com/fleetdm/fleet/v4/server/version.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/fleet"
  ];

  tags = [ "full" ];
  versionCheckProgramArg = "version";

  passthru = {
    inherit frontend;
  };

  meta = {
    description = "CLI tool to launch Fleet server";
    homepage = "https://github.com/fleetdm/fleet";
    changelog = "https://github.com/fleetdm/fleet/releases/tag/fleet-v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      asauzeau
      lesuisse
      bddvlpr
    ];

    mainProgram = "fleet";
  };
})
