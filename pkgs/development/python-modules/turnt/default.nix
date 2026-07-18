{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  flit-core,
  tomli,
}:

buildPythonPackage rec {
  pname = "turnt";
  version = "1.12.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4K7cqGwKErGbZ+dxVa06v8aIfrpVLC293d29QT+vsBw=";
  };

  checkPhase = ''
    runHook preCheck
    $out/bin/turnt test/*/*.t
    runHook postCheck
  '';

  build-system = [ flit-core ];

  dependencies = [
    click
    tomli
  ];

  pyproject = true;
  pythonImportsCheck = [ "turnt" ];

  meta = {
    description = "Snapshot testing tool";
    homepage = "https://github.com/cucapra/turnt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ leungbk ];
    mainProgram = "turnt";
  };
}
