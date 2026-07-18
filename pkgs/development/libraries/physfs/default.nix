{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  zlib,
}:

let
  generic =
    version: sha256:
    stdenv.mkDerivation rec {
      inherit version;
      pname = "physfs";

      src = fetchFromGitHub {
        inherit sha256;
        owner = "icculus";
        repo = "physfs";
        rev = "release-${version}";
      };

      patches = [
        (./. + "/dont-set-cmake-skip-rpath-${version}.patch")
      ];

      # https://github.com/icculus/physfs/commit/f7d24ce8486d9229207cca1ff98858fe60ffe583
      # but the patch wouldn't apply to physfs_2, so let's do a fuzzy sed.
      postPatch = ''
        sed '/^cmake_minimum_required/Is/VERSION [0-9]\.[0-9]/VERSION 3.5/' \
          -i CMakeLists.txt
      '';

      nativeBuildInputs = [
        cmake
        doxygen
      ];

      buildInputs = [ zlib ];
      doInstallCheck = true;

      installCheckPhase = ''
        ./test_physfs --version
      '';

      meta = {
        description = "Library to provide abstract access to various archives";
        homepage = "https://icculus.org/physfs/";
        changelog = "https://github.com/icculus/physfs/releases/tag/release-${version}";
        license = lib.licenses.zlib;
        platforms = lib.platforms.all;
        mainProgram = "test_physfs";
      };
    };

in
{
  physfs = generic "3.2.0" "sha256-FhFIshX7G3uHEzvHGlDIrXa7Ux6ThQNzVssaENs+JMw=";
  physfs_2 = generic "2.1.1" "sha256-hmS/bfszit3kD6B2BjnuV50XKueq2GcRaqyAKLkvfLc=";
}
