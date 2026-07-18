{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  coverage,
  pillow,
  pymongo,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "mongoengine";
  version = "0.29.1";

  src = fetchFromGitHub {
    owner = "MongoEngine";
    repo = "mongoengine";
    tag = "v${version}";
    hash = "sha256-trWCKmCa+q+qtzF0HKCZMnko1cvvpwJvczLFuKtB83E=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "coverage==4.2" "coverage" \
      --replace "pymongo>=3.4,<=4.0" "pymongo"
  '';

  propagatedBuildInputs = [
    pymongo
    six
  ];

  # tests require mongodb running in background
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pillow
    coverage
    blinker
  ];

  format = "setuptools";
  pythonImportsCheck = [ "mongoengine" ];

  meta = {
    description = "MongoEngine is a Python Object-Document Mapper for working with MongoDB";
    homepage = "http://mongoengine.org/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
