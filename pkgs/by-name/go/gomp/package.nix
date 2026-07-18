{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gomp";
  version = "1.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-Ixq9jtV56FKbh68jqmRd3lwpbMG00GcOUIpjzJhnSp0=";
  };

  doCheck = false; # tests require interactive terminal

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Tool for comparing Git branches";
    homepage = "https://github.com/MarkForged/GOMP";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
    platforms = lib.platforms.unix;
    mainProgram = "gomp";
  };
})
