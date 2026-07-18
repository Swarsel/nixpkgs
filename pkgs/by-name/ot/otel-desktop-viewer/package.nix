{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "otel-desktop-viewer";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "CtrlSpice";
    repo = "otel-desktop-viewer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9m1W2DxbMyBOGeECTn78X7I3GcToW5Gi33HWXGyWFO8=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk ];
  vendorHash = "sha256-WTaPggKaQJY9t16jES9gbsFNHOn4ujxHsqezKOYMdCs=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  # NOTE: This project uses Go workspaces, but 'buildGoModule' does not support
  # them at the time of writing; trying to build with 'env.GOWORK = "off"'
  # fails with the following error message:
  #
  #     main module (github.com/CtrlSpice/otel-desktop-viewer) does not contain package github.com/CtrlSpice/otel-desktop-viewer/desktopexporter
  #
  # cf. https://github.com/NixOS/nixpkgs/issues/203039
  proxyVendor = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Receive & visualize OpenTelemtry traces locally within one CLI tool";
    homepage = "https://github.com/CtrlSpice/otel-desktop-viewer";
    changelog = "https://github.com/CtrlSpice/otel-desktop-viewer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jkachmar
      lf-
    ];

    mainProgram = "otel-desktop-viewer";
  };
})
