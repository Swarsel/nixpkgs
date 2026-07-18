{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  libpg_query,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "squawk";
  version = "2.40.1";

  src = fetchFromGitHub {
    owner = "sbdchd";
    repo = "squawk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JpRuZDJSGl5mMakmjAvDYA/Q7yxr5wa0oYmGJOCeFZg=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libiconv
    openssl
  ];

  cargoHash = "sha256-ADia4CjTqhkccwpi8v2TStl+xlDpIeZfuVFvmSBwrCM=";

  env = {
    LIBPG_QUERY_PATH = libpg_query;
    OPENSSL_NO_VENDOR = 1;
  };

  checkFlags = [
    # depends on the PostgreSQL version
    "--skip=parse::tests::test_parse_sql_query_json"
  ];

  cargoBuildFlags = [
    "-p squawk"
  ];

  meta = {
    description = "Linter for PostgreSQL, focused on migrations";
    homepage = "https://squawkhq.com";
    changelog = "https://github.com/sbdchd/squawk/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = [ ];
  };
})
