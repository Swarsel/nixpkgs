{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  peewee,
  python,
  setuptools,
  wtforms,
}:

buildPythonPackage (finalAttrs: {
  pname = "wtf-peewee";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "coleifer";
    repo = "wtf-peewee";
    tag = finalAttrs.version;
    hash = "sha256-G/yhQ+/xKdK15YU3Ms5E2FLUk6ncJYd0Ys54R61jBtc=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} runtests.py
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    peewee
    wtforms
  ];

  pyproject = true;

  meta = {
    description = "WTForms integration for peewee models";
    homepage = "https://github.com/coleifer/wtf-peewee/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
