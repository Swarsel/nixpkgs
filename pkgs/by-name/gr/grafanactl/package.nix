{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "grafanactl";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "grafanactl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tlSV7yhk5ByiGm39IGo/PZHuHtyyV5QjHqDB5w3UWBM=";
  };

  vendorHash = "sha256-DOEByenSD4BCQuyyLQvJxC7/UkPmpHZemMEKZbOwLbE=";

  postInstall = ''
    rm $out/bin/cmd-reference
    rm $out/bin/config-reference
    rm $out/bin/env-vars-reference
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X main.version=v${finalAttrs.version}"
    "-X main.commit=unknown"
    "-X main.date=unknown"
  ];

  subPackage = [ "cmd/grafanactl" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool designed to simplify interaction with Grafana instances";
    homepage = "https://github.com/grafana/grafanactl";
    changelog = "https://github.com/grafana/grafanactl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ wcarlsen ];
    mainProgram = "grafanactl";
  };
})
