{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gotests";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "cweill";
    repo = "gotests";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-lx8gbVm4s4kmm252khoSukrlj5USQS+StGuJ+419QZw=";
  };

  vendorHash = "sha256-/dP8uA1yWBrtmFNHUvcicPhA2qr5R2v1uSwYi+ciypg=";
  # tests are broken in nix environment
  doCheck = false;

  meta = {
    description = "Generate Go tests from your source code";
    homepage = "https://github.com/cweill/gotests";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vdemeester ];
    mainProgram = "gotests";
  };
})
