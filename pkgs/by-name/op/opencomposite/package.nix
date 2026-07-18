{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  glm,
  jsoncpp,
  libGL,
  libx11,
  nix-update-script,
  openxr-loader,
  python3,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencomposite";
  version = "1.0.1521";

  src = fetchFromGitLab {
    owner = "znixian";
    repo = "OpenOVR";
    tag = finalAttrs.version;
    hash = "sha256-qi1iqlsr0P+Hw63O3ayCBIEGdNtkhl8FCPcs/m0WIzs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    glm
    jsoncpp
    libGL
    vulkan-headers
    vulkan-loader
    libx11
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-Wno-error=format-security")
    # See https://gitlab.com/znixian/OpenOVR/-/issues/416
    (lib.cmakeBool "USE_SYSTEM_OPENXR" false)
    (lib.cmakeBool "USE_SYSTEM_GLM" true)
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/opencomposite
    cp -r bin/ $out/lib/opencomposite
    touch $out/lib/opencomposite/bin/version.txt
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    # This can realistically only work on systems that support OpenXR Loader
    inherit (openxr-loader.meta) platforms;
    description = "Reimplementation of OpenVR, translating calls to OpenXR";
    homepage = "https://gitlab.com/znixian/OpenOVR";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ Scrumplex ];
  };
})
