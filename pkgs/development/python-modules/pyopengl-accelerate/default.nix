{
  buildPythonPackage,
  cython,
  numpy,
  pyopengl,
  setuptools,
}:

buildPythonPackage {
  inherit (pyopengl) version src;
  pname = "pyopengl-accelerate";

  build-system = [
    cython
    numpy
    setuptools
  ];

  pyproject = true;
  sourceRoot = "${pyopengl.src.name}/accelerate";

  meta = {
    inherit (pyopengl.meta) maintainers license;
    description = "This set of C (Cython) extensions provides acceleration of common operations for slow points in PyOpenGL 3.x";
    homepage = "https://github.com/mcfletch/pyopengl/tree/master/accelerate#readme";
  };
}
