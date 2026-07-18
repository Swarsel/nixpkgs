{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "addic7ed-cli";
  version = "1.4.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "182cpwxpdybsgl1nps850ysvvjbqlnx149kri4hxhgm58nqq0qf5";
  };

  # Tests require network access
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    requests
    pyquery
  ];

  pyproject = true;
  pythonImportsCheck = [ "addic7ed_cli" ];

  meta = {
    description = "Commandline access to addic7ed subtitles";
    homepage = "https://github.com/BenoitZugmeyer/addic7ed-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aethelz ];
    platforms = lib.platforms.unix;
    mainProgram = "addic7ed";
  };
})
