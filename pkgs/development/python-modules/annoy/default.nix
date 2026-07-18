{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  h5py,
  # tests
  numpy,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "annoy";
  version = "1.17.3";

  src = fetchFromGitHub {
    owner = "spotify";
    repo = "annoy";
    tag = "v${version}";
    hash = "sha256-oJHW4lULRun2in35pBGOKg44s5kgLH2BKiMOzVu4rf4=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'nose>=1.0'" ""
  '';

  nativeBuildInputs = [ h5py ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf annoy
  '';

  build-system = [ setuptools ];

  disabledTestPaths = [
    # network access
    "test/accuracy_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "annoy" ];

  meta = {
    description = "Approximate Nearest Neighbors in C++/Python optimized for memory usage and loading/saving to disk";
    homepage = "https://github.com/spotify/annoy";
    changelog = "https://github.com/spotify/annoy/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ timokau ];

    badPlatforms = [
      # Several tests fail with AssertionError
      lib.systems.inspect.patterns.isDarwin
    ];
  };
}
