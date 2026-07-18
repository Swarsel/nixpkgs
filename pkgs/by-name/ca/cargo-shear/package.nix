{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-shear";
  version = "1.13.1";

  src = fetchCrate {
    hash = "sha256-Luf6/kG0MgnBDyMLZGUSadPI60DOx5Jra3I3ezOGM4w=";
    pname = "cargo-shear";
    version = finalAttrs.version;
  };

  cargoHash = "sha256-d+3ZfygD4CzHLgT45KcCw2rr313eVO7PhGZpgJpbxW8=";

  env = {
    # https://github.com/Boshen/cargo-shear/blob/v1.6.2/src/lib.rs#L51-L54
    SHEAR_VERSION = finalAttrs.version;
  };

  # Integration tests require network access
  cargoTestFlags = [
    "--lib"
  ];

  passthru = {
    tests = {
      version = testers.testVersion {
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Detect and fix unused/misplaced dependencies from Cargo.toml";
    homepage = "https://github.com/Boshen/cargo-shear";
    changelog = "https://github.com/Boshen/cargo-shear/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.cathalmullan ];
    mainProgram = "cargo-shear";
  };
})
