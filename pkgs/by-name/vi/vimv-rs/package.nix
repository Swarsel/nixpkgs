{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vimv-rs";
  version = "3.1.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-jbRsgEsRYF5hlvo0jEB4jhy5jzCAXNzOsNWWyh4XULQ=";
    crateName = "vimv";
  };

  cargoHash = "sha256-A+Ba3OWQDAramwin1Yc1YDOyabuEEaZGhE1gel2tFoM=";

  meta = {
    description = "Command line utility for batch-renaming files";
    homepage = "https://www.dmulholl.com/dev/vimv.html";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ zowoq ];
    mainProgram = "vimv";
  };
})
