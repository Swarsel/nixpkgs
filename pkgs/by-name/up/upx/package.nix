{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "upx";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "upx";
    repo = "upx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6LTDz4gMak0V7KiZOeuQgm+RubKRp3zhF6T6SZzZ5Dk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Ultimate Packer for eXecutables";
    homepage = "https://upx.github.io/";
    changelog = "https://github.com/upx/upx/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "upx";
  };
})
