{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pew";
  version = "1.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "04anak82p4v9w0lgfs55s7diywxil6amq8c8bhli143ca8l2fcdq";
  };

  # no tests are packaged
  checkPhase = ''
    $out/bin/pew > /dev/null
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    virtualenv
    virtualenv-clone
    setuptools # pkg_resources is imported during runtime
  ];

  pyproject = true;
  pythonImportsCheck = [ "pew" ];

  meta = {
    description = "Tools to manage multiple virtualenvs written in pure python";
    homepage = "https://github.com/berdario/pew";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "pew";
  };
})
