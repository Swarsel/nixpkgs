{
  lib,
  buildPythonPackage,
  fetchPypi,
  oslotest,
  pbr,
  setuptools,
  stestr,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "oslo-context";
  version = "6.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5QT43wLFzOf8mE+Gf736qh1NS5uIl44pH25cuJ31o+A=";
    pname = "oslo_context";
  };

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    oslotest
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    pbr
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "oslo_context" ];

  meta = {
    description = "Oslo Context library";
    homepage = "https://github.com/openstack/oslo.context";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
