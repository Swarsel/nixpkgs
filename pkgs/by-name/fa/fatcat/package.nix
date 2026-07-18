{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gitUpdater,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fatcat";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Gregwar";
    repo = "fatcat";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/iGNVP7Bz/UZAR+dFxAKMKM9jm07h0x0F3VGpdxlHdk=";
  };

  patches = [
    # cmake: Set minimum required version to 3.5 for CMake 4+
    (fetchpatch {
      hash = "sha256-e5qGcpdHhbp2mZ7O3vBAJnSW5K2aXEfNVUfK/brx9a8=";
      url = "https://github.com/Gregwar/fatcat/commit/2e3476a84cbe32598d36b5506c21025b3f94eb03.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];

  env = {
    CXXFLAGS = "-std=c++11";
  };

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "FAT filesystems explore, extract, repair, and forensic tool";
    homepage = "https://github.com/Gregwar/fatcat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cynerd ];
    mainProgram = "fatcat";
  };
})
