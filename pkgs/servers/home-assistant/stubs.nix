{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  home-assistant,
  python,
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2026.7.2";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = "homeassistant-stubs";
    tag = version;
    hash = "sha256-QeUE2C3BZyOAF3le2wXWpW6g46chqANWOv1bAsSE8+U=";
  };

  postPatch = ''
    # Relax constraint to year and month
    substituteInPlace pyproject.toml --replace-fail \
      'homeassistant==${version}' \
      'homeassistant~=${lib.versions.majorMinor home-assistant.version}'
  '';

  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
    home-assistant
  ];

  disabled = python.version != home-assistant.python3Packages.python.version;
  pyproject = true;

  pythonImportsCheck = [
    "homeassistant-stubs"
  ];

  meta = {
    description = "Typing stubs for Home Assistant Core";
    homepage = "https://github.com/KapJI/homeassistant-stubs";
    changelog = "https://github.com/KapJI/homeassistant-stubs/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    teams = [ lib.teams.home-assistant ];
  };
}
