{
  lib,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "starry";
  version = "2.0.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-/ZUmMLEqlpqu+Ja/3XjFJf+OFZJCz7rp5MrQBEjwsXs=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-NNQhU6NVacRCzFp2hWcBvHvD6zPOlTvII8n7k505HrY=";

  meta = {
    description = "Current stars history tells only half the story";
    homepage = "https://github.com/Canop/starry";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "starry";
  };
})
