{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "evans";
  version = "0.10.11";

  src = fetchFromGitHub {
    owner = "ktr0731";
    repo = "evans";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-V5M7vXlBSQFX2YZ+Vjt63hLziWy0yuAbCMmSZFEO0OA=";
  };

  vendorHash = "sha256-oyFPycyQoYnN261kmGhkN9NMPMA6XChf4jXlYezKiCo=";
  subPackages = [ "." ];

  meta = {
    description = "More expressive universal gRPC client";
    homepage = "https://evans.syfm.me/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ diogox ];
    mainProgram = "evans";
  };
})
