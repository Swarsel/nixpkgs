{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  pico-sdk,
  versionCheckHook,
  # Options
  # The submodules in the pico-sdk contain important additional functionality
  # such as tinyusb, but not all these libraries might be bsd3.
  # Off by default.
  withSubmodules ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pico-sdk";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "pico-sdk";
    tag = finalAttrs.version;

    hash =
      if withSubmodules then
        "sha256-8ubZW6yQnUTYxQqYI6hi7s3kFVQhe5EaxVvHmo93vgk="
      else
        "sha256-hQdEZD84/cnLSzP5Xr9vbOGROQz4BjeVOnvbyhe6rfM=";

    fetchSubmodules = withSubmodules;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeFeature "PIOASM_VERSION_STRING" finalAttrs.version)
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/pico-sdk
    cp -a ../../../* $out/lib/pico-sdk/
    chmod 755 $out/lib/pico-sdk/tools/pioasm/build/pioasm
    runHook postInstall
  '';

  # SDK contains libraries and build-system to develop projects for RP2040 chip
  # We only need to compile pioasm binary
  sourceRoot = "${finalAttrs.src.name}/tools/pioasm";

  passthru = {
    tests = {
      withSubmodules = pico-sdk.override { withSubmodules = true; };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "SDK provides the headers, libraries and build system necessary to write programs for the RP2040-based devices";
    homepage = "https://github.com/raspberrypi/pico-sdk";
    changelog = "https://github.com/raspberrypi/pico-sdk/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ muscaln ];
    platforms = lib.platforms.unix;
  };
})
