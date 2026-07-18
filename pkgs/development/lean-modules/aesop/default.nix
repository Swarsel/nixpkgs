{
  lib,
  fetchFromGitHub,
  batteries,
  buildLakePackage,
}:

buildLakePackage {
  pname = "lean4-aesop";
  # nixpkgs-update: no auto update
  version = "4.30.0";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "aesop";
    tag = "v4.30.0";
    hash = "sha256-7PhQVMdiYImuzRYdf0Kgw3JYS4nBLfILXxyhFH8Zag0=";
  };

  leanDeps = [ batteries ];
  leanPackageName = "aesop";

  meta = {
    description = "White-box automation for Lean 4";
    homepage = "https://github.com/leanprover-community/aesop";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
}
