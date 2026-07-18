{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipython,
  numpy,
  pymupdf,
  setuptools,
  texliveSmall,
}:

buildPythonPackage {
  pname = "pytikz-allefeld"; # "pytikz" on pypi is a different module
  version = "unstable-2022-11-01";

  src = fetchFromGitHub {
    owner = "allefeld";
    repo = "pytikz";
    rev = "f878ebd6ce5a647b1076228b48181b147a61abc1";
    hash = "sha256-G59UUkpjttJKNBN0MB/A9CftO8tO3nv8qlTxt3/fKHk=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ texliveSmall ];

  checkPhase = ''
    runHook preCheck
    python -c 'if 1:
      from tikz import *
      pic = Picture()
      pic.draw(line([(0, 0), (1, 1)]))
      print(pic.code())
      pic.write_image("test.pdf")
    '
    test -s test.pdf
    runHook postCheck
  '';

  dependencies = [
    pymupdf
    numpy
    ipython
  ];

  pyproject = true;
  pythonImportsCheck = [ "tikz" ];

  meta = {
    description = "Python interface to TikZ";
    homepage = "https://github.com/allefeld/pytikz";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
