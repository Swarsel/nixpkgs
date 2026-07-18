{
  lib,
  stdenv,
  coreutils,
  jq,
  nix,
  python3,
  xz,
  zstd,
}:

# This function is for creating a flat-file binary cache, i.e. the kind created by
# nix copy --to file:///some/path and usable as a substituter (with the file:// prefix).

# For example, in the Nixpkgs repo:
# nix-build -E 'with import ./. {}; mkBinaryCache { rootPaths = [hello]; }'

{
  rootPaths,
  compression ? "zstd", # one of ["none" "xz" "zstd"]
  name ? "binary-cache",
}:

assert lib.elem compression [
  "none"
  "xz"
  "zstd"
];

stdenv.mkDerivation {
  inherit name;

  nativeBuildInputs = [
    coreutils
    jq
    python3
    nix
  ]
  ++ lib.optional (compression == "xz") xz
  ++ lib.optional (compression == "zstd") zstd;

  __structuredAttrs = true;

  buildCommand = ''
    mkdir -p $out/nar

    python ${./make-binary-cache.py} --compression "${compression}"

    # These directories must exist, or Nix might try to create them in LocalBinaryCacheStore::init(),
    # which fails if mounted read-only
    mkdir $out/realisations
    mkdir $out/debuginfo
    mkdir $out/log
  '';

  exportReferencesGraph.closure = rootPaths;
  preferLocalBuild = true;
}
