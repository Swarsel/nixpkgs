{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  oniguruma,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "marmite";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = "marmite";
    tag = version;
    hash = "sha256-Q07xA/TYI2O+8C0/3cTpZx0bt47lS+ilhxck18hzzCw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    oniguruma
  ];

  cargoHash = "sha256-yWl8AWond03tT1CsyCrX72AX5ysow6jPgEtFonpLSyc=";

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  meta = {
    description = "Static Site Generator for Blogs";
    homepage = "https://github.com/rochacbruno/marmite";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "marmite";
  };
}
