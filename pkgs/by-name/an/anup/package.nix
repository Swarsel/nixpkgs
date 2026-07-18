{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  sqlite,
  xdg-utils,
}:

rustPlatform.buildRustPackage rec {
  pname = "anup";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "jonathanlmc";
    repo = "anup";
    tag = version;
    hash = "sha256-4pXF4p4K8+YihVB9NdgT6bOidmQEgWXUbcbvgXJ0IDA=";
  };

  buildInputs = [
    sqlite
    xdg-utils
  ];

  cargoHash = "sha256-925R5pG514JiA7iUegFkxrDpA3o7T/Ct4Igqqcdo3rw=";

  meta = {
    description = "Anime tracker for AniList featuring a TUI";
    homepage = "https://github.com/jonathanlmc/anup";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ natto1784 ];
    mainProgram = "anup";
  };
}
