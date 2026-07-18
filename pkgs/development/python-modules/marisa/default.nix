{
  lib,
  buildPythonPackage,
  marisa,
  setuptools,
  swig,
}:

buildPythonPackage {
  inherit (marisa) src version;
  pname = "marisa";
  patches = marisa.patches or [ ];
  nativeBuildInputs = [ swig ];
  buildInputs = [ marisa ];

  preBuild = ''
    make -C bindings swig-python

    cd bindings/python
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "marisa" ];

  meta = {
    description = "Python bindings for marisa";
    homepage = "https://github.com/s-yata/marisa-trie";

    license = with lib.licenses; [
      bsd2
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
