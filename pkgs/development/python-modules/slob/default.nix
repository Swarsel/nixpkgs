{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pyicu,
  # tests
  python,
  # build-system
  setuptools,
}:

buildPythonPackage {
  pname = "slob";
  version = "0-unstable-2024-04-19";

  src = fetchFromGitHub {
    owner = "itkach";
    repo = "slob";
    rev = "c21d695707db7d2fe4ec7ec27a018bb7b0fcc209";
    hash = "sha256-dy/EaRLx0LwMklk4h2eL8CsyvWN4swcJNs5cULmh46g=";
  };

  # The tests are part of the same slob.py file, so unittestCheckHook which
  # runs python -m unittest with the `discover` argument which doesn't discover
  # any tests.
  checkPhase = ''
    ${python.interpreter} -m unittest slob
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    pyicu
  ];

  pyproject = true;
  pythonImportsCheck = [ "slob" ];

  meta = {
    description = "Reference implementation of the slob (sorted list of blobs) format";
    homepage = "https://github.com/itkach/slob/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "slob";
  };
}
