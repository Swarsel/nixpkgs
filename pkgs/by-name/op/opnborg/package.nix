{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "opnborg";
  version = "0.1.81";

  src = fetchFromGitHub {
    owner = "paepckehh";
    repo = "opnborg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lPPOGvWoeMkA5B488saJWFU7yG/RcjJ+e1p1O/ssW00=";
  };

  vendorHash = "sha256-B1fZsgb2h3Po4Zy9jUD6OOFAGr+Yw6vNBK+IurjzMSo=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/opnborg";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sefhosted OPNSense Appliance Backup & Configuration Management Portal";
    homepage = "https://paepcke.de/opnborg";
    changelog = "https://github.com/paepckehh/opnborg/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "opnborg";
  };
})
