{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "alerta";
  version = "8.5.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ePvT2icsgv+io5aDDUr1Zhfodm4wlqh/iqXtNkFhS10=";
  };

  doCheck = true;

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    requests-mock
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    click
    requests
    requests-hawk
    pytz
    tabulate
  ];

  # AlertTestCases attempt to connect to alerta api
  disabledTests = [ "AlertTestCase" ];
  pyproject = true;
  pythonImportsCheck = [ "alertaclient" ];

  meta = {
    description = "Alerta Monitoring System command-line interface";
    homepage = "https://alerta.io";
    license = lib.licenses.asl20;
    mainProgram = "alerta";
  };
})
