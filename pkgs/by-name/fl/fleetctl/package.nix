{
  lib,
  stdenv,
  buildGoModule,
  fleet,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  inherit (fleet) version src vendorHash;
  pname = "fleetctl";
  # Try to access /var/empty/.goquery/history subfolders
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  doInstallCheck = !stdenv.hostPlatform.isDarwin;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X github.com/fleetdm/fleet/v4/server/version.appName=fleetctl"
    "-X github.com/fleetdm/fleet/v4/server/version.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/fleetctl"
  ];

  meta = {
    description = "CLI tool for managing Fleet";
    homepage = "https://github.com/fleetdm/fleet";
    changelog = "https://github.com/fleetdm/fleet/releases/tag/fleet-v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lesuisse
    ];

    mainProgram = "fleetctl";
  };
})
