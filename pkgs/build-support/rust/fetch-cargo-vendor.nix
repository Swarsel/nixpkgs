{
  lib,
  cacert,
  cargo,
  gitMinimal,
  nix-prefetch-git,
  python3,
  runCommand,
  stdenvNoCC,
  writers,
}:

let
  python = python3.override {
    packageOverrides = final: prev: {
      # The ast-serialize package, a dependency for mypy, depends on
      # fetchCargoVendor and is part of the bootstrap chain for requests.
      charset-normalizer = prev.charset-normalizer.override { withMypyc = false; };
    };

    self = python;
  };
  python3Packages = python.pkgs;

  replaceWorkspaceValues = writers.writePython3Bin "replace-workspace-values" {
    flakeIgnore = [
      "E501"
      "W503"
    ];

    libraries = with python3Packages; [
      tomli
      tomli-w
    ];
  } (builtins.readFile ./replace-workspace-values.py);

  nix-prefetch-git' = nix-prefetch-git.override {
    git = gitMinimal;
    # break loop of nix-prefetch-git -> git-lfs -> asciidoctor -> ruby (yjit) -> fetchCargoVendor -> nix-prefetch-git
    # Cargo does not currently handle git-lfs: https://github.com/rust-lang/cargo/issues/9692
    git-lfs = null;
  };

  removedArgs = [
    "name"
    "pname"
    "version"
    "nativeBuildInputs"
    "hash"
  ];

  fetchCargoVendorUtil = writers.writePython3Bin "fetch-cargo-vendor-util" {
    flakeIgnore = [
      "E501"
    ];

    libraries =
      with python3Packages;
      [
        requests
        tomli-w
      ]
      ++ requests.optional-dependencies.socks; # to support socks proxy envs like ALL_PROXY in requests
  } (builtins.readFile ./fetch-cargo-vendor-util.py);
in

{
  hash ? (throw "fetchCargoVendor requires a `hash` value to be set for ${name}"),
  name ? if args ? pname && args ? version then "${args.pname}-${args.version}" else "cargo-deps",
  nativeBuildInputs ? [ ],
  ...
}@args:

# TODO: add asserts about pname version and name

let
  vendorStaging = stdenvNoCC.mkDerivation (
    {
      strictDeps = true;

      nativeBuildInputs = [
        fetchCargoVendorUtil
        cacert
        nix-prefetch-git'
      ]
      ++ nativeBuildInputs;

      buildPhase = ''
        runHook preBuild

        if [ -n "''${cargoRoot-}" ]; then
          cd "$cargoRoot"
        fi

        fetch-cargo-vendor-util create-vendor-staging ./Cargo.lock "$out"

        runHook postBuild
      '';

      dontConfigure = true;
      dontFixup = true;
      dontInstall = true;
      impureEnvVars = lib.fetchers.proxyImpureEnvVars;
      name = "${name}-vendor-staging";
      outputHash = hash;
      outputHashAlgo = if hash == "" then "sha256" else null;
      outputHashMode = "recursive";
    }
    // removeAttrs args removedArgs
  );
in
runCommand "${name}-vendor"
  {
    inherit vendorStaging;

    nativeBuildInputs = [
      fetchCargoVendorUtil
      cargo
      replaceWorkspaceValues
    ];
  }
  ''
    fetch-cargo-vendor-util create-vendor "$vendorStaging" "$out"
  ''
