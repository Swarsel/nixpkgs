{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-fancy-pypi-readme,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hijridate";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "dralshehri";
    repo = "hijridate";
    tag = "v${version}";
    hash = "sha256-xnFF81l1ZqtH91NzYvjzXpXpN/zeHdARJYx6L5VNBSo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  pyproject = true;
  pythonImportsCheck = [ "hijridate" ];

  meta = {
    description = "Accurate Hijri-Gregorian date converter based on the Umm al-Qura calendar";
    homepage = "https://github.com/dralshehri/hijridate";
    changelog = "https://github.com/dralshehri/hijridate/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
