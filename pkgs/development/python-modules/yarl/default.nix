{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  expandvars,
  hypothesis,
  idna,
  multidict,
  propcache,
  pydantic,
  pytest-codspeed,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "yarl";
  version = "1.24.2";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "yarl";
    tag = "v${version}";
    hash = "sha256-GEe2GDXmqsQgWB0UxPZVMdSco3j2JYHg9BU9M6oqynw=";
  };

  nativeCheckInputs = [
    hypothesis
    pydantic
    pytest-codspeed
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ];

  preCheck = ''
    # don't import yarl from ./ so the C extension is available
    pushd tests
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    cython
    expandvars
    setuptools
  ];

  dependencies = [
    idna
    multidict
    propcache
  ];

  pyproject = true;
  pythonImportsCheck = [ "yarl" ];

  meta = {
    description = "Yet another URL library";
    homepage = "https://github.com/aio-libs/yarl";
    changelog = "https://github.com/aio-libs/yarl/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
