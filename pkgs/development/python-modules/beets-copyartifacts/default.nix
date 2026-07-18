{
  lib,
  fetchFromGitHub,
  # nativeBuildInputs
  beets-minimal,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  # dependencies
  six,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "beets-copyartifacts";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "adammillerio";
    repo = "beets-copyartifacts";
    tag = "v${version}";
    hash = "sha256-fMnXuMwxylO9Q7EFPpkgwwNeBuviUa8HduRrqrqdMaI=";
  };

  nativeBuildInputs = [
    beets-minimal
  ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    six
  ];

  pyproject = true;

  pytestFlags = [
    # This is the same as:
    #   -r fEs
    "-rfEs"
  ];

  meta = {
    inherit (beets-minimal.meta) platforms;
    description = "Beets plugin to move non-music files during the import process";
    homepage = "https://github.com/adammillerio/beets-copyartifacts";
    changelog = "https://github.com/adammillerio/beets-copyartifacts/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    broken = true;
  };
}
