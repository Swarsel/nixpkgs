{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  gtest,
  libdwarf,
  libunwind,
  nix-update-script,
  pkg-config,
  zstd,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpptrace";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "cpptrace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KmAJEEU1aTKwleGBllSxlrsO4jVSTKnSTQQZyJ50loY=";
  };

  patches = [
    ./0001-Use-libdwarf-2-as-the-base-include-path.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    (lib.getDev libdwarf)
    libunwind
  ];

  propagatedBuildInputs = [
    zstd
  ]
  ++ (lib.optionals static [
    libdwarf
    libunwind
  ]);

  cmakeFlags = [
    (lib.cmakeBool "CPPTRACE_USE_EXTERNAL_LIBDWARF" true)
    (lib.cmakeBool "CPPTRACE_FIND_LIBDWARF_WITH_PKGCONFIG" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!static))
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "CPPTRACE_USE_EXTERNAL_GTEST" true)
    (lib.cmakeBool "CPPTRACE_UNWIND_WITH_LIBUNWIND" true)
  ];

  doCheck = true;
  checkInputs = [ gtest ];

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    dsymutil unittest
  '';

  passthru = {
    tests =
      let
        mkIntegrationTest =
          { static }:
          callPackage ./findpackage-integration.nix {
            inherit static;
            src = "${finalAttrs.src}/test/findpackage-integration";
            checkOutput = finalAttrs.finalPackage.doCheck;
          };
      in
      {
        findpackage-integration-shared = mkIntegrationTest { static = false; };
        findpackage-integration-static = mkIntegrationTest { static = true; };
      };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple, portable, and self-contained stacktrace library for C++11 and newer";
    homepage = "https://github.com/jeremy-rifkin/cpptrace";
    changelog = "https://github.com/jeremy-rifkin/cpptrace/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xokdvium ];
    platforms = lib.platforms.all;
  };
})
