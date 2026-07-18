{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  fetchpatch,
  # tests
  fixtures,
  networkx,
  # dependencies
  numpy,
  pytestCheckHook,
  rustPlatform,
  rustc,
  # build-system
  setuptools,
  setuptools-rust,
  testtools,
}:

buildPythonPackage (finalAttrs: {
  pname = "rustworkx";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "rustworkx";
    tag = finalAttrs.version;
    hash = "sha256-aBKGJwm9EmGwLOhIx6qTuDco5uNcnwUlZf3ztFzmIGs=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-oUosh1pu/I6Zpg2Di/Gnp5SCwetgs9HDY96Q2bQ7R6M=";
      name = "networkx-3.6-test-compat.patch";
      url = "https://github.com/Qiskit/rustworkx/commit/04780a59005d0a80bdc3e22427566aea86783eb8.patch";
    })
  ];

  # Otherwise, `rust-src` is required
  # https://github.com/Qiskit/rustworkx/pull/1447
  postPatch = ''
    rm -rf .cargo/config.toml
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  nativeCheckInputs = [
    fixtures
    networkx
    pytestCheckHook
    testtools
  ];

  preCheck = ''
    rm -r rustworkx
  '';

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-2jqyXk6xWpSGdpaVGu7YW9643MBYDfl3A6InFw/cCUM=";
  };

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "rustworkx" ];

  meta = {
    description = "High performance Python graph library implemented in Rust";
    homepage = "https://github.com/Qiskit/rustworkx";
    changelog = "https://github.com/Qiskit/rustworkx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
