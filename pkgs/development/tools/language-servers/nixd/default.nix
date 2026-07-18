{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  gtest,
  llvmPackages,
  meson,
  mesonEmulatorHook,
  ninja,
  nix-update-script,
  nixVersions,
  nixd,
  nixf,
  nixt,
  nlohmann_json,
  pkg-config,
  python3,
  testers,
}:

let
  nixComponents = nixVersions.nixComponents_2_34;
  common = rec {
    version = "2.9.1";

    src = fetchFromGitHub {
      owner = "nix-community";
      repo = "nixd";
      tag = version;
      hash = "sha256-S/E16Yf3Qh098qXxl0pimSy/5gkkd1n/Os6B9REWleg=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      meson
      ninja
      python3
      pkg-config
      llvmPackages.llvm # workaround for a meson bug, where llvm-config is not found, making the build fail
    ];

    doCheck = true;
    mesonBuildType = "release";

    meta = {
      homepage = "https://github.com/nix-community/nixd";
      changelog = "https://github.com/nix-community/nixd/releases/tag/${version}";
      license = lib.licenses.lgpl3Plus;

      maintainers = with lib.maintainers; [
        inclyc
        Ruixi-rebirth
        aleksana
        redyf
      ];

      platforms = lib.platforms.unix;
    };
  };
in
{
  nixd = stdenv.mkDerivation (
    common
    // {
      pname = "nixd";
      nativeBuildInputs = common.nativeBuildInputs ++ [ cmake ];

      buildInputs = [
        nixComponents.nix-main
        nixComponents.nix-expr
        nixComponents.nix-cmd
        nixComponents.nix-flake
        nixf
        nixt
        llvmPackages.llvm
        gtest
        boost
      ];

      # See https://github.com/nix-community/nixd/issues/519
      doCheck = false;
      sourceRoot = "${common.src.name}/nixd";

      passthru = {
        tests.version = testers.testVersion { package = nixd; };
        updateScript = nix-update-script { };
      };

      meta = common.meta // {
        description = "Feature-rich Nix language server interoperating with C++ nix";
        mainProgram = "nixd";
      };
    }
  );

  nixf = stdenv.mkDerivation (
    common
    // {
      pname = "nixf";

      outputs = [
        "out"
        "dev"
      ];

      nativeBuildInputs =
        common.nativeBuildInputs
        ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [ mesonEmulatorHook ];

      buildInputs = [
        nixComponents.nix-expr
        gtest
        boost
        nlohmann_json
      ];

      sourceRoot = "${common.src.name}/libnixf";

      passthru.tests.pkg-config = testers.hasPkgConfigModules {
        moduleNames = [ "nixf" ];
        package = nixf;
      };

      meta = common.meta // {
        description = "Nix language frontend, parser & semantic analysis";
        mainProgram = "nixf-tidy";
      };
    }
  );

  nixt = stdenv.mkDerivation (
    common
    // {
      pname = "nixt";

      outputs = [
        "out"
        "dev"
      ];

      buildInputs = [
        nixComponents.nix-main
        nixComponents.nix-expr
        nixComponents.nix-cmd
        nixComponents.nix-flake
        gtest
        boost
      ];

      sourceRoot = "${common.src.name}/libnixt";

      passthru.tests.pkg-config = testers.hasPkgConfigModules {
        moduleNames = [ "nixt" ];
        package = nixt;
      };

      meta = common.meta // {
        description = "Supporting library that wraps C++ nix";
      };
    }
  );
}
