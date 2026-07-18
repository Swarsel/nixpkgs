{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "gdlv";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "aarzilli";
    repo = "gdlv";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jR19vfYfIeXe0k3/S0Zjft9abND0uN8o2Z8SllgpUYw=";
  };

  vendorHash = null;
  subPackages = ".";

  meta = {
    description = "GUI frontend for Delve";
    homepage = "https://github.com/aarzilli/gdlv";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ mmlb ];
    mainProgram = "gdlv";
  };
})
