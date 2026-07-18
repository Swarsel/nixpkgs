{
  lib,
  fetchFromGitHub,
  fetchpatch,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "formatjson5";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "google";
    repo = "json5format";
    # Not tagged, see Cargo.toml.
    rev = "056829990bab4ddc78c65a0b45215708c91b8628";
    hash = "sha256-Lredw/Fez+2U2++ShZcKTFCv8Qpai9YUvqvpGjG5W0o=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-kAbRUL/FuhnxkC9Xo4J2bXt9nkMOLeJvgMmOoKnSxKc=";
      # bugfix: fix missing_docs error
      # Needed to build with Rust 1.83+.
      name = "0001-bugfix-fix-missing-docs-error";
      url = "https://github.com/google/json5format/commit/32914546e7088b3d9173ae9a2f307effa87917bf.patch";
    })
    (fetchpatch {
      hash = "sha256-ZY7Ck51/vHcRDQ5GEwOuMIF+QiYNGay3wbIvesmEl9k=";
      # Skip rewriting unchanged files with --replace
      # Unmerged upstream patch, ensures json5format is compatible with treefmt(-nix),
      # which is quite popular in the Nix ecosystem.
      name = "0002-skip-rewriting-unchanged-files";
      url = "https://github.com/google/json5format/commit/7bb67ff03529f6f0350d72b7a36839f20fe9d190.patch";
    })
  ];

  cargoHash = "sha256-1CSt9dPVHdOqfQXio7/eXiDLWt+iOe6Qj+VtWblwSDE=";

  postInstall =
    let
      cargoTarget = rustPlatform.cargoInstallHook.targetSubdirectory;
    in
    ''
      install -D target/${cargoTarget}/release/examples/formatjson5 $out/bin/formatjson5
    '';

  cargoBuildFlags = [ "--example formatjson5" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "JSON5 formatter";
    homepage = "https://github.com/google/json5format";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ katexochen ];
    mainProgram = "formatjson5";
  };
}
