{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  opencl-headers,
  withTracing ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencl-icd-loader";
  version = "2026.05.29";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-ICD-Loader";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PUfYCf2+0i+SatQerehPv97LOTDlBsQAmtHFX97UGzo=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ opencl-headers ];

  cmakeFlags = [
    (lib.cmakeBool "OCL_ICD_ENABLE_TRACE" withTracing)
  ];

  meta = {
    description = "Official Khronos OpenCL ICD Loader";
    homepage = "https://github.com/KhronosGroup/OpenCL-ICD-Loader";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "cllayerinfo";
  };
})
