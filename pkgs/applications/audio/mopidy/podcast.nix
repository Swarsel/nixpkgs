{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-podcast";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-grNPVEVM2PlpYhBXe6sabFjWVB9+q+apIRjcHUxH52A=";
    pname = "Mopidy-Podcast";
  };

  nativeCheckInputs = [
    pythonPackages.pytestCheckHook
  ];

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.cachetools
    pythonPackages.uritools
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_podcast" ];

  meta = {
    description = "Mopidy extension for browsing and playing podcasts";
    homepage = "https://github.com/tkem/mopidy-podcast";
    license = lib.licenses.asl20;

    maintainers = [
      lib.maintainers.daneads
    ];
  };
})
