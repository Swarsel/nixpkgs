{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  objgraph,
  psutil,
  pytest-codspeed,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "multidict";
  version = "6.7.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "multidict";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HOQRfSxf0+HeXsV4ShwfUDjNVyg2SjNuE157JLRlAL0=";
  };

  postPatch = ''
    # `python3 -I -c "import multidict"` fails with ModuleNotFoundError
    substituteInPlace tests/test_circular_imports.py \
      --replace-fail '"-I",' ""
  '';

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-command-line-argument";
  };

  nativeCheckInputs = [
    objgraph
    psutil
    pytestCheckHook
    pytest-codspeed
    pytest-cov-stub
  ];

  preCheck = ''
    # import from $out
    rm -r multidict
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "multidict" ];

  meta = {
    description = "Multidict implementation";
    homepage = "https://github.com/aio-libs/multidict/";
    changelog = "https://github.com/aio-libs/multidict/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
