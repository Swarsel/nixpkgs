{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  giflib,
  lcms2,
  libhwy,
  libpng,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ssimulacra2";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "cloudinary";
    repo = "ssimulacra2";
    rev = "tags/v${finalAttrs.version}";
    hash = "sha256-gOo8WCWMdXOSmny0mQSzCvHgURQTCNBFD4G4sxfmXik=";
  };

  nativeBuildInputs = [
    ninja
    cmake
  ];

  buildInputs = [
    libpng
    (libhwy.overrideAttrs rec {
      version = "0.15.0";

      src = fetchFromGitHub {
        owner = "google";
        repo = "highway";
        rev = version;
        hash = "sha256-v2HyyHtBydr7QiI83DW1yRv2kWjUOGxFT6mmdrN9XPo=";
      };

      patches = [ ];

      postPatch = ''
        substituteInPlace CMakeLists.txt --replace-fail "set(CMAKE_CXX_STANDARD 11)" "set(CMAKE_CXX_STANDARD 17)"
      '';
    })
    lcms2
    giflib
  ];

  installPhase = ''
    runHook preInstall
    install -m 755 -D ssimulacra2 -t $out/bin/
    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Perceptual image comparison tool";
    homepage = "https://github.com/cloudinary/ssimulacra2";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.viraptor ];
    broken = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  };
})
