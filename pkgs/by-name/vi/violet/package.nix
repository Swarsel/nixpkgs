{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "violet";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "paullouisageneau";
    repo = "violet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OBrEydVqhbxJZED8mUjV605kvtbXPqb35X1XeNBNvjg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  passthru = {
    tests = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight STUN/TURN server";
    homepage = "https://github.com/paullouisageneau/violet";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ oluceps ];
    platforms = lib.platforms.all;
    mainProgram = "violet";
  };
})
