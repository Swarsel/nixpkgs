{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "askalono";
  version = "0.5.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-LwyUaU4m9fk+mG8FBfkbj9nBvd8KokwlV7cE7EBwk0Q=";
    pname = "askalono-cli";
  };

  cargoHash = "sha256-ug79p75Oa5lsd9COWO2aIx3jN7de1QZggMFiOPAN5kQ=";

  meta = {
    description = "Tool to detect open source licenses from texts";
    homepage = "https://github.com/jpeddicord/askalono";
    changelog = "https://github.com/jpeddicord/askalono/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "askalono";
  };
})
