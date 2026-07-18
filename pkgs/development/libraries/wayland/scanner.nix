{
  lib,
  stdenv,
  expat,
  libxml2,
  meson,
  ninja,
  pkg-config,
  testers,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (wayland) version src;
  pname = "wayland-scanner";

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ]
  ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) wayland-scanner;

  buildInputs = [
    expat
    libxml2
  ];

  mesonFlags = [
    (lib.mesonBool "documentation" false)
    (lib.mesonBool "libraries" false)
    (lib.mesonBool "tests" false)
  ];

  depsBuildBuild = [ pkg-config ];
  separateDebugInfo = true;

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };
  };

  meta = {
    inherit (wayland.meta) homepage license maintainers;
    description = "C code generator for Wayland protocol XML files";
    platforms = lib.platforms.unix;
    mainProgram = "wayland-scanner";
    pkgConfigModules = [ "wayland-scanner" ];
  };
})
