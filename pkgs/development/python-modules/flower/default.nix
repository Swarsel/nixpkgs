{
  lib,
  buildPythonPackage,
  celery,
  fetchPypi,
  humanize,
  prometheus-client,
  pytestCheckHook,
  pytz,
  tornado,
}:

buildPythonPackage rec {
  pname = "flower";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WrcXuXlTB3DBavtItQ0qmNI8Pp/jmFHc9rxNAYRaAqA=";
  };

  postPatch = ''
    # rely on using example programs (flowers/examples/tasks.py) which
    # are not part of the distribution
    rm tests/load.py
  '';

  propagatedBuildInputs = [
    celery
    humanize
    prometheus-client
    pytz
    tornado
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  format = "setuptools";
  pythonImportsCheck = [ "flower" ];

  meta = {
    description = "Real-time monitor and web admin for Celery distributed task queue";
    homepage = "https://github.com/mher/flower";
    license = lib.licenses.bsdOriginal;
    maintainers = [ ];
  };
}
