{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
  pkg-config,
  sparsehash,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "afsctool";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "RJVB";
    repo = "afsctool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-irWPQnnV5mHZS7pw9PAWp6MO/3MahKaOIZCr6awcwEg=";
    fetchSubmodules = true;

    gitConfigFile = builtins.toFile "gitconfig" ''
      [url "https://github.com/"]
      insteadOf = "git://github.com/"
    '';
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    git
  ];

  buildInputs = [
    zlib
    sparsehash
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  meta = {
    description = "Utility that allows end-users to leverage HFS+/APFS compression";
    homepage = "https://github.com/RJVB/afsctool";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = lib.platforms.darwin;
  };
})
