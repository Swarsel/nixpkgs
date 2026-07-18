{
  lib,
  stdenv,
  fetchFromGitHub,
  cli11,
  cmake,
  gtest,
  libcap,
  libseccomp,
  nlohmann_json,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linyaps-box";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = "linyaps-box";
    rev = finalAttrs.version;
    hash = "sha256-KULNPztaDeO6Dih98KcnawMz2rDjQd6AYT9FgAADhIg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cli11
    gtest
    libcap
    libseccomp
    nlohmann_json
  ];

  cmakeFlags = [
    (lib.cmakeBool "linyaps-box_ENABLE_SECCOMP" true)
  ];

  meta = {
    description = "Simple OCI runtime mainly used by linyaps";
    homepage = "https://github.com/OpenAtom-Linyaps/linyaps-box";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "ll-box";
  };
})
