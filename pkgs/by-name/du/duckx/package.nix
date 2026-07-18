{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "duckx";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "amiremohamadi";
    repo = "DuckX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qRqYcBi/a2tUSlLAa7DKPqwQsctw5/0hjV/Og1pHPQU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
    # CMake 3.0 is deprecated and is no longer supported by CMake > 4
    # https://github.com/NixOS/nixpkgs/issues/445447
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    # https://github.com/amiremohamadi/DuckX/issues/92
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "14")
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "C++ library for creating and modifying Microsoft Word (.docx) files";
    homepage = "https://github.com/amiremohamadi/DuckX";
    changelog = "https://github.com/amiremohamadi/DuckX/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ titaniumtown ];
  };
})
