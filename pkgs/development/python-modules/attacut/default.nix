{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  fetchpatch,
  fire,
  numpy,
  pytestCheckHook,
  python-crfsuite,
  pyyaml,
  setuptools,
  six,
  ssg,
  torch,
}:

buildPythonPackage rec {
  pname = "attacut";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "PyThaiNLP";
    repo = "attacut";
    tag = "v${version}";
    hash = "sha256-x3JJC1Xd+tsOAHJEHGzIrhIrNGSvLSanAFc7+uXb2Kk=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-k2DJPwiH1Fyf5u6+zavx0bankCXsJVZrw1MGcf8ZL+M=";
      includes = [ "attacut/evaluation.py" ];
      name = "fix-nptyping-deprecated-array.patch";
      url = "https://github.com/PyThaiNLP/attacut/commit/a707297b3f08a015d32d8ac241aa8cb11128cbd4.patch";
    })
  ];

  # no more need, see patch...
  postPatch = ''
    sed -i "/nptyping>=/d" setup.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    docopt
    fire
    numpy
    python-crfsuite
    pyyaml
    six
    ssg
    torch
  ];

  enabledTestPaths = [ "tests/*" ];
  pyproject = true;
  pythonImportsCheck = [ "attacut" ];

  meta = {
    description = "Fast and Accurate Neural Thai Word Segmenter";
    homepage = "https://github.com/PyThaiNLP/attacut";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "attacut-cli";
  };
}
