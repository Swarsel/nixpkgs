{
  lib,
  bc-decaf,
  bc-mbedtls,
  bcunit,
  mkLinphoneDerivation,
  # tests
  testers,
}:
mkLinphoneDerivation (finalAttrs: {
  pname = "bctoolbox";
  strictDeps = true;

  propagatedBuildInputs = [
    bcunit
    bc-decaf
    bc-mbedtls
  ];

  cmakeFlags = [
    "-DENABLE_STRICT=NO"

    "-DENABLE_MBEDTLS=YES"
    "-DENABLE_OPENSSL=NO"
  ];

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [
        "BCToolbox"
      ];

      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Utilities library for Linphone";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      jluttine
      naxdy
      raskin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bctoolbox_tester";
  };
})
