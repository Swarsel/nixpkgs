{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "tcat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "rsc";
    repo = "tcat";
    rev = "v${finalAttrs.version}";
    sha256 = "1szzfz5xsx9l8gjikfncgp86hydzpvsi0y5zvikd621xkp7g7l21";
  };

  vendorHash = null;
  subPackages = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Table cat";
    homepage = "https://github.com/rsc/tcat";
    license = lib.licenses.bsd3;

    maintainers = [
      lib.maintainers.mmlb
    ];

    mainProgram = "tcat";
  };
})
