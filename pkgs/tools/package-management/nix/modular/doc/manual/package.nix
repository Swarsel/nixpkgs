{
  lib,
  jq,
  json-schema-for-humans,
  lowdown-unsandboxed,
  mdbook,
  meson,
  mkMesonDerivation,
  ninja,
  nix-cli,
  python3,
  rsync,
  # Configuration Options
  version,
}:

mkMesonDerivation (finalAttrs: {
  inherit version;
  pname = "nix-manual";

  # TODO the man pages should probably be separate
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
    (lib.getBin lowdown-unsandboxed)
    mdbook
    jq
    python3
    rsync
  ]
  ++ lib.optionals (lib.versionAtLeast (lib.versions.majorMinor version) "2.33") [
    json-schema-for-humans
  ]
  ++ [
    nix-cli
  ];

  preConfigure = ''
    chmod u+w ./.version
    echo ${finalAttrs.version} > ./.version
  '';

  postInstall = ''
    mkdir -p ''$out/nix-support
    echo "doc manual ''$out/share/doc/nix/manual" >> ''$out/nix-support/hydra-build-products
  '';

  workDir = ./.;

  meta = {
    platforms = lib.platforms.all;
  };
})
