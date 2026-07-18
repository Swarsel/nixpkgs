{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  keyutils,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "keyutils";
  version = "0.6";

  # github version comes bundled with tests
  src = fetchFromGitHub {
    owner = "sassoftware";
    repo = "python-keyutils";
    rev = version;
    sha256 = "0pfqfr5xqgsqkxzrmj8xl2glyl4nbq0irs0k6ik7iy3gd3mxf5g1";
  };

  postPatch = ''
    substituteInPlace setup.py --replace '"pytest-runner"' ""
  '';

  nativeBuildInputs = [ cython ];
  buildInputs = [ keyutils ];

  preBuild = ''
    cython keyutils/_keyutils.pyx
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf keyutils
  '';

  format = "setuptools";

  meta = {
    description = "Set of python bindings for keyutils";
    homepage = "https://github.com/sassoftware/python-keyutils";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
