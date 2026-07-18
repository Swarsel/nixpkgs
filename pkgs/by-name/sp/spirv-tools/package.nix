{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  python3,
  spirv-headers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spirv-tools";
  version = "1.4.350.0";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "vulkan-sdk-${finalAttrs.version}";
    hash = "sha256-tR3POZH/LXaAljMUS9aHBBvIvlr6o7d6+YUtJCRMS1w=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [
    # https://github.com/KhronosGroup/SPIRV-Tools/pull/6483
    ./0001-Fix-generated-pkg-config-modules-with-absolute-insta.patch

    # backport to fix glslang tests
    # FIXME: remove in next update
    (fetchpatch {
      hash = "sha256-YHbYBwXMm4rTKpmMW6I3LUafhA4RuNUdXqUBUAXwXpE=";
      url = "https://github.com/KhronosGroup/SPIRV-Tools/commit/2ec8457ab33d539b6f1fecc998360c0b8b05ed4f.diff";
    })
  ]
  # The cmake options are sufficient for turning on static building, but not
  # for disabling shared building, just trim the shared lib from the CMake
  # description
  ++ lib.optional stdenv.hostPlatform.isStatic ./no-shared-libs.patch;

  nativeBuildInputs = [
    cmake
    python3
  ];

  cmakeFlags = [
    "-DSPIRV-Headers_SOURCE_DIR=${spirv-headers}"
    # Avoid blanket -Werror to evade build failures on less
    # tested compilers.
    "-DSPIRV_WERROR=OFF"
  ];

  meta = {
    description = "SPIR-V Tools project provides an API and commands for processing SPIR-V modules";
    homepage = "https://github.com/KhronosGroup/SPIRV-Tools";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.ralith ];
    platforms = with lib.platforms; unix ++ windows;
  };
})
