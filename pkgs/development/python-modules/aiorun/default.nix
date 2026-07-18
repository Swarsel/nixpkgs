{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pygments,
  pytestCheckHook,
  uvloop,
}:

buildPythonPackage rec {
  pname = "aiorun";
  version = "2025.1.1";

  src = fetchFromGitHub {
    owner = "cjrh";
    repo = "aiorun";
    tag = "v${version}";
    hash = "sha256-YqUlWf79EbC47BETBDjo8hzg5jhL4LiWLKGr1Qy4AbM=";
  };

  preBuild = ''
    export HOME=$TMPDIR
  '';

  nativeCheckInputs = [
    pytestCheckHook
    uvloop
  ];

  build-system = [ flit-core ];
  dependencies = [ pygments ];
  pyproject = true;
  pythonImportsCheck = [ "aiorun" ];

  meta = {
    description = "Boilerplate for asyncio applications";
    homepage = "https://github.com/cjrh/aiorun";
    changelog = "https://github.com/cjrh/aiorun/blob/v${version}/CHANGES";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
