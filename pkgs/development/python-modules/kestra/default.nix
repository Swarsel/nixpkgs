{
  lib,
  fetchFromGitHub,
  amazon-ion,
  buildPythonPackage,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "kestra";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "kestra-io";
    repo = "libs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z03wLcu0tDe0UJgY9bLX+ozACpgGBPg99W67m3MsStc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
    pytest-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    amazon-ion
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "kestra" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Infinitely scalable orchestration and scheduling platform, creating, running, scheduling, and monitoring millions of complex pipelines";
    homepage = "https://github.com/kestra-io/libs";
    changelog = "https://github.com/kestra-io/libs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ DataHearth ];
  };
})
