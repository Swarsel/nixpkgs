{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "melody";
  version = "0.20.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-u+d16jc7GqT2aK2HzP+OXFUBkVodwcW+20sKqmxzYhk=";
    pname = "melody_cli";
  };

  cargoHash = "sha256-TNW36FLK1E6uoDICfGN5ZmTX8V9ndSqyif7tbBqvqDI=";

  meta = {
    description = "Language that compiles to regular expressions";
    homepage = "https://github.com/yoav-lavi/melody";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "melody";
  };
})
