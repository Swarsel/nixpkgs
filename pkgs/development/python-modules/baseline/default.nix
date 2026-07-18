{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "baseline";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "dmgass";
    repo = "baseline";
    rev = "95a0b71806ed16310eb0f27bc48aa5e21f731423";
    hash = "sha256-DQTd3OYo7gCaKAlnCKuwmHPq47kl44/lpk46f6MhT2I=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  disabled = !isPy3k;
  pyproject = true;
  pythonImportsCheck = [ "baseline" ];

  meta = {
    description = "Easy String Baseline";

    longDescription = ''
      This tool streamlines creation and maintenance of tests which compare
      string output against a baseline.
    '';

    homepage = "https://github.com/dmgass/baseline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dnr ];
    mainProgram = "baseline";
  };
}
