{
  lib,
  fetchFromGitHub,
  # overridden as pkgs.brotli
  brotli,
  buildPythonPackage,
  cffi,
  hypothesis,
  isPyPy,
  pycparser,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "brotlicffi";
  version = "1.2.0.0";

  src = fetchFromGitHub {
    owner = "python-hyper";
    repo = "brotlicffi";
    tag = "v${version}";
    hash = "sha256-3/68qBfsFtH+7h3gPxUdkyHwG6qLbh+bVLrxzsb3bc4=";
  };

  buildInputs = [ brotli ];

  preBuild = ''
    export USE_SHARED_BROTLI=1
  '';

  # Test data is only available from libbrotli git checkout, not brotli.src
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [ setuptools ];
  dependencies = [ cffi ] ++ lib.optional isPyPy pycparser;
  enabledTestPaths = [ "test/" ];
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "brotlicffi" ];

  meta = {
    description = "Python CFFI bindings to the Brotli library";
    homepage = "https://github.com/python-hyper/brotlicffi";
    changelog = "https://github.com/python-hyper/brotlicffi/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
