{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "helmsman";
  version = "4.0.5";

  src = fetchFromGitHub {
    owner = "mkubaczyk";
    repo = "helmsman";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-TeP7M0Mtd3rx9hcRCvgJAs7fBx2SZwUZSAhI/yhaO6k=";
  };

  vendorHash = "sha256-i3qZ0OSV40oB8X3seixXMeji6CpcSiNK5wTbxF+TFpI=";
  doCheck = false;
  subPackages = [ "cmd/helmsman" ];

  meta = {
    description = "Helm Charts (k8s applications) as Code tool";
    homepage = "https://github.com/Praqma/helmsman";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lynty
      sarcasticadmin
    ];

    mainProgram = "helmsman";
  };
})
