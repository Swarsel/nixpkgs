{
  lib,
  fetchFromGitHub,
  borgbackup,
  buildPythonPackage,
  cython,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "msgpack";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "msgpack";
    repo = "msgpack-python";
    tag = "v${version}";
    hash = "sha256-9iFTQPAM6AAogcRUoCw5/bECNiGUwmAarEiwMJ+rqbk=";
  };

  nativeBuildInputs = [ cython ];

  preBuild = ''
    make cython
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "msgpack" ];

  passthru.tests = {
    # borgbackup is sensible to msgpack versions: https://github.com/borgbackup/borg/issues/3753
    # please be mindful before bumping versions.
    inherit borgbackup;
  };

  meta = {
    description = "MessagePack serializer implementation";
    homepage = "https://github.com/msgpack/msgpack-python";
    changelog = "https://github.com/msgpack/msgpack-python/blob/${src.tag}/ChangeLog.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
