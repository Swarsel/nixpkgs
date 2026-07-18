{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "spdx-license-list";
  version = "3.28.0";

  src = fetchFromGitHub {
    owner = "JJMC89";
    repo = "spdx-license-list";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qzEWa2SY4XfW+DgAl6UNUItYWGJ/dJM6jZ/ZekoVgNc=";
  };

  # upstream has no tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  pyproject = true;

  pythonImportsCheck = [
    "spdx_license_list"
  ];

  meta = {
    description = "SPDX License List as a Python dictionary";
    homepage = "https://github.com/JJMC89/spdx-license-list";
    changelog = "https://github.com/JJMC89/spdx-license-list/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
