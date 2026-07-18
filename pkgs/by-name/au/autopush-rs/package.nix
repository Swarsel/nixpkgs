{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  grpc,
  libffi,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  pkgs,
  python3Packages,
  rustPlatform,
}:
let
  #script to generate the fernet key
  fernetKey =
    {
      src,
      version,
    }:
    python3Packages.buildPythonApplication {
      inherit version src;
      pname = "fernet_key";

      installPhase = ''
        mkdir -p $out/bin
        echo "#!/usr/bin/env python3" |  \
        cat - $src/scripts/fernet_key.py > $out/bin/fernet_key
        chmod +x $out/bin/fernet_key
      '';

      postFixup = ''
        wrapPythonPrograms
      '';

      __structuredAttrs = true;
      dependencies = [ python3Packages.cryptography ];
      # this would run the upstream docker makefile
      dontBuild = true;
      format = "other";
    };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "autopush";
  version = "1.82.1";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "autopush-rs";
    tag = finalAttrs.version;
    hash = "sha256-wOnuYh18q2XDAcCUBGsidAMvOi10s4njVKDLhtNJEoU=";
  };

  outputs = [
    "out"
    "fernet"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    cmake
  ];

  buildInputs = [
    openssl
    libffi
    grpc
  ];

  cargoHash = "sha256-FiMEDc2wxQPkM50cNKzP8yo90HGMakn6JUl/xheaciQ=";

  env = {
    #needed for bingen to find libc
    BINDGEN_EXTRA_CLANG_ARGS = "-I${stdenv.cc.libc.dev}/include";
    CMAKE_POLICY_VERSION_MINIMUM = "3.5";
  };

  #check build fails
  doCheck = false;

  postInstall = ''
    mkdir -p $fernet/bin
    ln -s ${fernetKey { inherit (finalAttrs) src version; }}/bin/fernet_key $fernet/bin/fernet_key
  '';

  __structuredAttrs = true;

  buildFeatures = [
    "postgres"
    "redis"
    "reliable_report"
  ];

  # by default only google bigtable is supported as a db
  buildNoDefaultFeatures = true;

  passthru = {
    services.autoconnect = {
      imports = [
        (lib.modules.importApply ./service-autoconnect.nix { inherit pkgs; })
      ];

      package = finalAttrs.finalPackage.out;
    };

    services.autoendpoint = {
      imports = [
        (lib.modules.importApply ./service-autoendpoint.nix { inherit pkgs; })
      ];

      package = finalAttrs.finalPackage.out;
    };

    tests = nixosTests.autopush-rs;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Mozilla Push server and Push Endpoint";
    homepage = "https://mozilla-services.github.io/autopush-rs/index.html";
    changelog = "https://github.com/mozilla-services/autopush-rs/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = [
      lib.maintainers.zimward
    ];

    platforms = lib.platforms.linux;

    # install the fernet_key script in devshells as users will only use it once most likely
    outputsToInstall = [
      "out"
      "fernet"
    ];
  };
})
