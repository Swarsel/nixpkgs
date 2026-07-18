{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  libiconv,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "ruff-api";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "amyreese";
    repo = "ruff-api";
    tag = "v${version}";
    hash = "sha256-4ekNPgOOqRIVjIR8LNSALE7fByjMEn8y25y9Rdvf+ms=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  # Tests have issues at the moment, check with next update
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-SqouHcEDehxNnNPdrkDUYx8AieHiPMs04RgrkdqYcpU=";
  };

  pyproject = true;
  pythonImportsCheck = [ "ruff_api" ];

  meta = {
    description = "Experimental Python API for Ruff";
    homepage = "https://github.com/amyreese/ruff-api";
    changelog = "https://github.com/amyreese/ruff-api/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
