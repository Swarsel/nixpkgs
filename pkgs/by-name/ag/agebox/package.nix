{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "agebox";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "slok";
    repo = "agebox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/FTNvGV7PsJmpSU1dI/kjfiY5G7shomvLd3bvFqORfg=";
  };

  vendorHash = "sha256-s3LZgQpUF0t9ETNloJux4gXXSn5Kg+pcuhJSMfWWnSo=";

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Age based repository file encryption gitops tool";
    homepage = "https://github.com/slok/agebox";
    changelog = "https://github.com/slok/agebox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lesuisse ];
    mainProgram = "agebox";
  };
})
