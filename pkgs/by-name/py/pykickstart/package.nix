{
  lib,
  fetchFromGitHub,
  gettext,
  gitMinimal,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pykickstart";
  version = "3.75";

  src = fetchFromGitHub {
    owner = "pykickstart";
    repo = "pykickstart";
    tag = "r${finalAttrs.version}";
    hash = "sha256-3tQ5tXUx2L3I0SyxVKgNRFv0AwYeG88vZOdSZDxj1Ks=";
  };

  nativeBuildInputs = [
    gettext
    gitMinimal
  ];

  # All checks are for RedHat's weird translation library.
  # Can't package it and not really necessary so disable them.
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pykickstart" ];

  meta = {
    description = "Python package to interact with Kickstart files commonly found in the RPM world";
    homepage = "https://github.com/pykickstart/pykickstart";
    changelog = "https://github.com/pykickstart/pykickstart/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thefossguy
    ];
  };
})
