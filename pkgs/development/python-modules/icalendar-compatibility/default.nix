{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  hatch-vcs,
  hatchling,
  icalendar,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "icalendar-compatibility";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "niccokunzmann";
    repo = "icalendar_compatibility";
    tag = "v${version}";
    hash = "sha256-h9rpbltNEPMteicPJ6oC32NsZS8QXQphLbC0Qiu7j5Q=";
  };

  # hatch-vcs tries to read the current git commit hash
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'dynamic = ["urls", "version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    git
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ icalendar ];

  disabledTests = [
    # https://github.com/niccokunzmann/icalendar_compatibility/issues/5
    "test_geo_location_is_also_escaped"
  ];

  pyproject = true;
  pythonImportsCheck = [ "icalendar_compatibility" ];

  meta = {
    homepage = "https://icalendar-compatibility.readthedocs.io/en/latest/";
    changelog = "https://icalendar-compatibility.readthedocs.io/en/latest/changes.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ erictapen ];
  };

}
