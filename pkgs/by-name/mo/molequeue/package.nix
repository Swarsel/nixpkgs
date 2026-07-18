{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "molequeue";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "OpenChemistry";
    repo = "molequeue";
    tag = finalAttrs.version;
    hash = "sha256-+NoY8YVseFyBbxc3ttFWiQuHQyy1GN8zvV1jGFjmvLg=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.3 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ qt5.qttools ];

  # Fix the broken CMake files to use the correct paths
  postInstall = ''
    substituteInPlace $out/lib/cmake/molequeue/MoleQueueConfig.cmake \
      --replace-fail "$out/" ""
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Desktop integration of high performance computing resources";
    homepage = "https://github.com/OpenChemistry/molequeue";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sheepforce ];
    platforms = lib.platforms.linux;
    mainProgram = "molequeue";
  };
})
