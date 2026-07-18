{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  mktestdocs,
  # nativeBuildInputs
  pkg-config,
  pkgs,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "tantivy";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "quickwit-oss";
    repo = "tantivy-py";
    tag = finalAttrs.version;
    hash = "sha256-VmymAxkGPFwqmsy5Y9d1/vBGUUU3xeSEteJLQIMt0FY=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [
    pkgs.zstd
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  nativeCheckInputs = [
    mktestdocs
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf tantivy
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-RXpwDEd7RmsSySMHZJy0wH56cp+tNgimjMNSNE55Zv4=";
  };

  pyproject = true;
  pythonImportsCheck = [ "tantivy" ];

  meta = {
    description = "Official Python bindings for the Tantivy search engine";
    homepage = "https://pypi.org/project/tantivy";
    changelog = "https://github.com/quickwit-oss/tantivy-py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
