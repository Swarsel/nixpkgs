{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  khronos-ocl-icd-loader,
  opencl-headers,
  python3,
  ruby,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencl-clhpp";
  version = "2026.05.29";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-CLHPP";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-VrI6cufrIXUizV2exKnQ5B1zjKzWsX5imp3ON39BkSw=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ];

  propagatedBuildInputs = [ opencl-headers ];

  cmakeFlags = [
    (lib.cmakeBool "OPENCL_CLHPP_BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "BUILD_EXAMPLES" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;
  nativeCheckInputs = [ ruby ];
  checkInputs = [ khronos-ocl-icd-loader ];

  passthru.tests = {
    pkg-config = testers.hasPkgConfigModules {
      moduleNames = [ "OpenCL-CLHPP" ];
      package = finalAttrs.finalPackage;
      # Package version does not match the pkg-config module version.
    };
  };

  meta = {
    description = "OpenCL Host API C++ bindings";
    homepage = "http://github.khronos.org/OpenCL-CLHPP/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.xokdvium ];
    platforms = lib.platforms.unix;
  };
})
