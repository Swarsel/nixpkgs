{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  rustPlatform,
}:
buildPythonPackage (finalAttrs: {
  pname = "opendal";
  version = "0.46.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OQGpz6o4R0Yp+1vAgFtik/l7wvHwJNcB1BhZLk+BFPg=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  env = {
    PYO3_USE_ABI3_FORWARD_COMPATIBILITY = 1;
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    python-dotenv
  ];

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  pyproject = true;
  pythonImportsCheck = [ "opendal" ];
  sourceRoot = "${finalAttrs.src.name}/bindings/python";

  meta = {
    description = "native Python binding for Apache OpenDAL";
    homepage = "https://github.com/apache/opendal/blob/main/bindings/python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
