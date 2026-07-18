{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  geojson,
  hatchling,
  pytestCheckHook,
  requests,
  requests-mock,
  versioningit,
}:

buildPythonPackage rec {
  pname = "datapoint";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "Perseudonymous";
    repo = "datapoint-python";
    tag = version;
    hash = "sha256-vgwuoG/2Lzo56cAiXEYNPsXQYfx8Cwg0NJgojDBxoug=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    hatchling
    versioningit
  ];

  dependencies = [
    appdirs
    geojson
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "datapoint" ];

  meta = {
    description = "Python interface to the Met Office's Datapoint API";
    homepage = "https://github.com/Perseudonymous/datapoint-python";
    changelog = "https://github.com/Perseudonymous/datapoint-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
