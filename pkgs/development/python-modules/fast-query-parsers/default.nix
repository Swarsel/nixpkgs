{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  poetry-core,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "fast-query-parsers";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "litestar-org";
    repo = "fast-query-parsers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gxKySLbBtX/6bXuTtiFw50UhmUwZE8lDaQ5P/g09Qnk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cargo
    poetry-core
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-eMZBKG5j9v3EVVwa7ooZcuIZK5ljeyc+2k1dw3O/TcQ=";
  };

  pyproject = true;
  pythonImportsCheck = [ "fast_query_parsers" ];

  meta = {
    description = "Ultra-fast query string and url-encoded form-data parsers";
    homepage = "https://github.com/litestar-org/fast-query-parsers";
    changelog = "https://github.com/litestar-org/fast-query-parsers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
