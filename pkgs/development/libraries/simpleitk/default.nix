{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  elastix,
  itk,
  lua,
  swig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simpleitk";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "SimpleITK";
    repo = "SimpleITK";
    tag = "v${finalAttrs.version}";
    hash = "sha256-biCrtfewxptDGHlN6xGmsv+m4RGgWDIBu7zMfa8XIRg=";
  };

  nativeBuildInputs = [
    cmake
    swig
  ];

  buildInputs = [
    elastix
    lua
    itk
  ];

  # 2.0.0: linker error building examples
  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DSimpleITK_USE_ELASTIX=ON"
  ];

  meta = {
    description = "Simplified interface to ITK";
    homepage = "https://www.simpleitk.org";
    changelog = "https://github.com/SimpleITK/SimpleITK/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.linux;
  };
})
