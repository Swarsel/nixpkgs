{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  pytest-asyncio,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "primp";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "deedy5";
    repo = "primp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VNb/U68NXmfH7eY8JOEk0z2yOUD4R/kFI1IShWS0pU4=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  # Tests crash with Abort trap: 6 on Darwin due to tokio runtime
  # initialization in PyInit_pyo3_async_runtimes being blocked by the sandbox.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  __structuredAttrs = true;
  buildAndTestSubdir = "crates/primp-python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-fnOCsxR0/6AnVO7n2M92WIA6kbyOkI6fwQh5QLnsxSc=";
  };

  disabledTestPaths = [
    "crates/primp-python/tests/test_impersonate.py"
    "crates/primp-python/tests/test_header_order.py"
  ];

  pyproject = true;

  # pytest runs from the source root but asyncio_mode=auto is configured in
  # crates/primp-python/pyproject.toml, which pytest doesn't pick up from there
  pytestFlags = [
    "--override-ini=asyncio_mode=auto"
  ];

  pythonImportsCheck = [ "primp" ];

  meta = {
    description = " HTTP client that can impersonate web browsers";
    homepage = "https://github.com/deedy5/primp";
    changelog = "https://github.com/deedy5/primp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drawbu ];
  };
})
