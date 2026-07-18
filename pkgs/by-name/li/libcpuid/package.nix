{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcpuid";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "anrieff";
    repo = "libcpuid";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+/TTlGk1ePPTHrSTSZmPHT2h3gKs9ouCF4ElvLWHF/g=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Small C library for CPU detection and feature extraction";
    homepage = "https://libcpuid.sourceforge.net/";
    changelog = "https://raw.githubusercontent.com/anrieff/libcpuid/master/ChangeLog";
    license = lib.licenses.bsd2;

    maintainers = [
    ];

    platforms = lib.platforms.x86 ++ lib.platforms.arm ++ lib.platforms.aarch64;
    mainProgram = "cpuid_tool";
  };
})
