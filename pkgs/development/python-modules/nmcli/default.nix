{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  networkmanager,
  replaceVars,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "nmcli";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "ushiboy";
    repo = "nmcli";
    tag = "v${version}";
    hash = "sha256-x3P+bayBG8SKnMxacIE9UQSE6GFqCX47Z4xtrFJOoRg=";
  };

  patches = [
    (replaceVars ./nmcli-path.patch {
      nmcli = lib.getExe' networkmanager "nmcli";
    })
  ];

  build-system = [
    setuptools
    wheel
  ];

  pyproject = true;

  meta = {
    inherit (networkmanager.meta) platforms;
    description = "Python library for interacting with NetworkManager CLI";
    homepage = "https://github.com/ushiboy/nmcli";
    changelog = "https://github.com/ushiboy/nmcli/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ktechmidas ];
  };
}
