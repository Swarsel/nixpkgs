{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  bash-completion,
  cmake,
  libconfig,
  libusbgx,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gt";
  version = "0-unstable-2022-05-08";

  src = fetchFromGitHub {
    owner = "linux-usb-gadgets";
    repo = "gt";
    rev = "7f9c45d98425a27444e49606ce3cf375e6164e8e";
    sha256 = "sha256-km4U+t4Id2AZx6GpH24p2WNmvV5RVjJ14sy8tWLCQsk=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    asciidoc
  ];

  buildInputs = [
    bash-completion
    libconfig
    libusbgx
  ];

  preConfigure = ''
    cmakeFlagsArray+=("-DBASH_COMPLETION_COMPLETIONSDIR=$out/share/bash-completions/completions")
  '';

  sourceRoot = "${finalAttrs.src.name}/source";

  meta = {
    description = "Linux command line tool for setting up USB gadgets using configfs";
    homepage = "https://github.com/linux-usb-gadgets/gt";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "gt";
  };
})
