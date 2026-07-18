{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  iniparser,
  meson,
  ninja,
  nix-update-script,
  python3,
  ruby,
  testers,
  validatePkgConfig,
  # Adds test groups and extra CLI flags.
  buildFixture ? false,
  # Adds the ablilty to track malloc and free calls.
  # Note that if fixtures are enabled, this option is ignored
  # and will always be enabled.
  buildMemory ? buildFixture,
  # Adds double precision floating point assertions
  supportDouble ? false,
}:
let
  # On newer versions of Clang, Weverything is too much of everything.
  ignoredErrors = [
    "-Wno-unsafe-buffer-usage"
    "-Wno-reserved-identifier"
    "-Wno-extra-semi-stmt"
    "-Wno-implicit-void-ptr-cast"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "unity-test";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "ThrowTheSwitch";
    repo = "Unity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g0ubq7RxGQmL1R6vz9RIGJpVWYsgrZhsTWSrL1ySEug=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # The meson file does not have the subdir set correctly
    (fetchpatch2 {
      hash = "sha256-r8ldVb7WrzVwTC2CtGul9Jk4Rzt+6ejk+paYAfFlR5M=";
      url = "https://patch-diff.githubusercontent.com/raw/ThrowTheSwitch/Unity/pull/771.patch";
    })
    # Fix up the shebangs in the auto directory as not all are correct
    (fetchpatch2 {
      hash = "sha256-K+OxMe/ZMXPPjZXjGhgc5ULLN7plBwL0hV5gwmgA3FM=";
      url = "https://patch-diff.githubusercontent.com/raw/ThrowTheSwitch/Unity/pull/790.patch";
    })
  ];

  postPatch = ''
    patchShebangs --build auto
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    python3
    validatePkgConfig
  ];

  # For the helper shebangs
  buildInputs = [
    python3
    ruby
  ];

  mesonFlags = [
    (lib.mesonBool "extension_memory" buildMemory)
    (lib.mesonBool "extension_fixture" buildFixture)
    (lib.mesonBool "support_double" supportDouble)
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    make -C../test -j $NIX_BUILD_CORES ${lib.optionalString stdenv.cc.isClang "CC=clang"} E="-Weverything ${lib.escapeShellArgs ignoredErrors}" test

    runHook postCheck
  '';

  # Various helpers
  postInstall = ''
    mkdir -p "$out/share"
    install -Dm755 ../auto/* -t "$out/share/"
  '';

  passthru = {
    tests = {
      inherit iniparser;

      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
        versionCheck = true;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Unity Unit Testing Framework";
    homepage = "https://www.throwtheswitch.org/unity";
    changelog = "https://github.com/ThrowTheSwitch/Unity/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      i01011001
      RossSmyth
    ];

    platforms = lib.platforms.all;
    pkgConfigModules = [ "unity" ];
  };
})
