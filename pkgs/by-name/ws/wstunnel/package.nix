{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wstunnel";
  version = "10.6.1";

  src = fetchFromGitHub {
    owner = "erebe";
    repo = "wstunnel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iQ1GmLhljUnf4FiK21phPxKUP5Wn0Si3ldC9Coxnv2E=";
  };

  nativeBuildInputs = [ versionCheckHook ];
  cargoHash = "sha256-hBzaMhNV1fat0I2UCcXndA/DOQkK96SVBm69VQlvBtY=";

  checkFlags = [
    # Tries to launch a test container
    "--skip=tcp::tests::test_proxy_connection"
    "--skip=protocols::tcp::server::tests::test_proxy_connection"
  ];

  doInstallCheck = true;
  cargoBuildFlags = [ "--package wstunnel-cli" ];

  passthru = {
    tests = {
      nixosTest = nixosTests.wstunnel;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tunnel all your traffic over Websocket or HTTP2 - Bypass firewalls/DPI";
    homepage = "https://github.com/erebe/wstunnel";
    changelog = "https://github.com/erebe/wstunnel/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      raylas
      rvdp
      neverbehave
    ];

    mainProgram = "wstunnel";
  };
})
