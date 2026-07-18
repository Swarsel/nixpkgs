{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "renson-endura-delta";
  version = "1.7.2";

  # github repo is gone
  src = fetchPypi {
    inherit version;
    hash = "sha256-bL4faNFh+ocNNspZCXE6/UZ4nH3mKkHSAEvwtN0xfoE=";
    pname = "renson_endura_delta";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'" ""
  '';

  doCheck = false; # no tests in sdist

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "renson_endura_delta" ];

  meta = {
    description = "Module to interact with Renson endura delta";
    homepage = "https://github.com/jimmyd-be/Renson-endura-delta-library";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
