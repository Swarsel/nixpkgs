{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "watchgha";
  version = "2.7.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-EWk/h5eusjgowj6C6h8RgAxkgqju4Ni3A/wWaeDQ3GQ=";
    pname = "watchgha";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    dulwich
    exceptiongroup
    httpx
    rich
    trio
  ];

  pyproject = true;
  pythonImportsCheck = [ "watchgha" ];

  meta = {
    description = "Live display of current GitHub action runs";
    homepage = "https://github.com/nedbat/watchgha";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ purcell ];
    platforms = lib.platforms.all;
    mainProgram = "watch_gha_runs";
  };
})
