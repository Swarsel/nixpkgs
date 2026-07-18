{
  lib,
  buildPythonPackage,
  contexter,
  eventlet,
  fetchPypi,
  mock,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "signalslot";
  version = "0.2.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ZNodibNGfCOa8xd3myN+cRa28rY3/ynNUia1kwjTIOU=";
    pname = "signalslot";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace-fail "--pep8 --cov" "" \
      --replace-fail "--cov-report html" ""
  '';

  nativeCheckInputs = [
    eventlet
    mock
    pytest-xdist
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    contexter
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "signalslot" ];

  meta = {
    description = "Simple Signal/Slot implementation";
    homepage = "https://github.com/numergy/signalslot";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ myaats ];
  };
})
