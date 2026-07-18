{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cmake,
  fetchpatch2,
  ninja,
  versionCheckHook,
}:

let
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "quick-lint";
    repo = "quick-lint-js";
    tag = version;
    hash = "sha256-L2LCRm1Fsg+xRdPc8YmgxDnuXJo92nxs862ewzObZ3I=";
  };

  cmakeFlags = [
    (lib.cmakeBool "QUICK_LINT_JS_ENABLE_BUILD_TOOLS" true)

    # Temporary workaround for https://github.com/NixOS/nixpkgs/pull/108496#issuecomment-1192083379
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)

    # CMake 4 dropped support of versions lower than 3.5,
    # versions lower than 3.10 are deprecated.
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  quick-lint-js-build-tools = buildPackages.stdenv.mkDerivation {
    inherit version src;
    inherit cmakeFlags;
    pname = "quick-lint-js-build-tools";

    nativeBuildInputs = [
      cmake
      ninja
    ];

    doCheck = false;

    installPhase = ''
      runHook preInstall
      cmake --install . --component build-tools
      runHook postInstall
    '';

    ninjaFlags = "quick-lint-js-build-tools";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  inherit cmakeFlags;
  pname = "quick-lint-js";

  patches = [
    (fetchpatch2 {
      hash = "sha256-jEzFFntk94HQPNYLqU1XlwCnhaqt95Kk3TXmfqBGxBc=";
      url = "https://github.com/quick-lint/quick-lint-js/commit/a2798b35021f34bc798e2b70ec703075dd5eb7f6.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  doCheck = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    # Expose quick-lint-js-build-tools to nix repl as quick-lint-js.build-tools.
    build-tools = quick-lint-js-build-tools;
  };

  meta = {
    description = "Find bugs in Javascript programs";
    homepage = "https://quick-lint-js.com";
    changelog = "https://github.com/quick-lint/quick-lint-js/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ratsclub ];
    platforms = lib.platforms.all;
    mainProgram = "quick-lint-js";
    downloadPage = "https://github.com/quick-lint/quick-lint-js";
  };
})
