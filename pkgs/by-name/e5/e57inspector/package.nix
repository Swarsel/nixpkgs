{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  nixosTests,
  qt6,
  xercesc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "e57inspector";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "sisakat";
    repo = "e57inspector";
    tag = "v${finalAttrs.version}";
    hash = "sha256-McLPbvS7j+6UVEcQ34/ngGiCxsdF/Whs5wZt5cP2UkI=";
    fetchSubmodules = true;
  };

  patches = [
    # Support loading E57 files from CLI arguments,
    # so we can use that in the NixOS VM test to load a sample file.
    # Remove with next release (see https://github.com/sisakat/e57inspector/pull/8)
    (fetchpatch {
      hash = "sha256-QRUv0CvX+OdH88CzI/6XjPXnAVIsf6N/Ix/qqCsSaRw=";
      name = "e57inspector-Allow-loading-file-from-CLI.patch";
      url = "https://github.com/nh2/e57inspector/commit/a5a899ee58952ffc2971d18b3734ea405e0020f3.patch";
    })
  ];

  postPatch = ''
    # Fix cmake_minimum_required version compatibility with CMake >= 4.0
    substituteInPlace app/cmake/gitversion.cmake \
      --replace-fail "cmake_minimum_required(VERSION 3.0.0)" "cmake_minimum_required(VERSION 3.5)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    xercesc
  ];

  # Upstream CMakeLists.txt has no install() rules.
  installPhase = ''
    runHook preInstall

    install -Dm755 app/e57inspector -t $out/bin
    install -Dm755 panorama/e57inspector_panorama -t $out/bin

    runHook postInstall
  '';

  __structuredAttrs = true;
  passthru.tests = nixosTests.e57inspector;

  meta = {
    description = "Cross-platform E57 file viewer to list and view stored point clouds, images and metadata";
    homepage = "https://github.com/sisakat/e57inspector";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      nh2
      chpatrick
    ];

    platforms = lib.platforms.linux;
    mainProgram = "e57inspector";
    teams = [ lib.teams.geospatial ];
  };
})
