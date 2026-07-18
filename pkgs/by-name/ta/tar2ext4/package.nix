{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "tar2ext4";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "hcsshim";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-n/YYajbQo+s1ssPAbS4gUdFYBHNmoNBKcEM/kcAZR94=";
  };

  vendorHash = null;
  sourceRoot = "${finalAttrs.src.name}/cmd/tar2ext4";

  meta = {
    description = "Convert a tar archive to an ext4 image";
    homepage = "https://github.com/microsoft/hcsshim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qyliss ];
    mainProgram = "tar2ext4";
  };
})
