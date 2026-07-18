{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "meraki-cli";
  version = "1.5.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-FHcKgppclc0L6yuCkpVYfr+jq8hNkt7Hq/44mpHMR20=";
    pname = "meraki_cli";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    requests-mock
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    argcomplete
    jinja2
    meraki
    rich
  ];

  disabledTests = [
    # requires files not in PyPI tarball
    "TestDocVersions"
    "TestHelps"
    # requires running "pip install"
    "TestUpgrade"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "meraki_cli"
  ];

  meta = {
    description = "Simple CLI tool to automate and control your Cisco Meraki Dashboard";
    homepage = "https://github.com/PackeTsar/meraki-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dylanmtaylor ];
    platforms = lib.platforms.unix;
    mainProgram = "meraki";
  };
})
