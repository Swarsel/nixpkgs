{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  nose2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "inotify";
  version = "0.2.12";

  src = fetchFromGitHub {
    owner = "dsoprea";
    repo = "PyInotify";
    tag = version;
    hash = "sha256-x6wvrwLDH/9UMTsAIHwCKR5Avv1givlJFFeBM//FOdg=";
  };

  nativeCheckInputs = [
    nose2
    pytestCheckHook
  ];

  build-system = [
    build
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Monitor filesystems events on Linux platforms with inotify";
    homepage = "https://github.com/dsoprea/PyInotify";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
