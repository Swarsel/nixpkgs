{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  testers,
  unstableGitUpdater,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libweaver";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitHub {
    owner = "isledecomp";
    repo = "SIEdit";
    rev = "2c32d65dbab577bf3a8701bc8bcae9034a7815d9";
    hash = "sha256-qtE7c/LCQBhVWgbdmu4e5mCo+4Pz6QkAY29dHG/Fi/U=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    (lib.cmakeBool "LIBWEAVER_BUILD_APP" false)
  ];

  __structuredAttrs = true;

  passthru = {
    tests.cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "libweaver" ];
      package = finalAttrs.finalPackage;
    };

    updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
  };

  meta = {
    description = "library for interacting with SI files";
    homepage = "https://github.com/isledecomp/SIEdit/tree/master/include/libweaver";
    license = lib.licenses.gpl3Only;

    maintainers = [
      lib.maintainers.RossSmyth
    ];
  };
})
