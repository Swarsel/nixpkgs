{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  packaging,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "pyinstaller-versionfile";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "DudeNr33";
    repo = "pyinstaller-versionfile";
    tag = "v${version}";
    hash = "sha256-UNrXP5strO6LIkIM3etBo1+Vm+1lR5wF0VfKtZYRoYc=";
  };

  propagatedBuildInputs = [
    packaging
    jinja2
    pyyaml
  ];

  preBuild = ''
    touch requirements.txt
  '';

  format = "setuptools";

  meta = {
    description = "Create a windows version-file from a simple YAML file that can be used by PyInstaller";
    homepage = "https://pypi.org/project/pyinstaller-versionfile/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "create-version-file";
  };
}
