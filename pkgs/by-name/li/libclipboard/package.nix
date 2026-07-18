{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libxau,
  libxcb,
  libxdmcp,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libclipboard";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jtanx";
    repo = "libclipboard";
    rev = "v${finalAttrs.version}";
    hash = "sha256-553hNG8QUlt/Aff9EKYr6w279ELr+2MX7nh1SKIklhA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libxcb
    libxau
    libxdmcp
  ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];

  meta = {
    description = "Lightweight cross-platform clipboard library";
    homepage = "https://jtanx.github.io/libclipboard";
    changelog = "https://github.com/jtanx/libclipboard/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sigmanificient ];
    platforms = lib.platforms.unix;
  };
})
