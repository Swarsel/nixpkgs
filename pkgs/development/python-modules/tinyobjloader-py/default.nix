{
  lib,
  buildPythonPackage,
  pybind11,
  tinyobjloader,
}:

buildPythonPackage {
  inherit (tinyobjloader) version src;
  pname = "tinyobjloader-py";
  buildInputs = [ pybind11 ];

  # Build needs headers from ${src}, setting sourceRoot or fetching from pypi won't work.
  preConfigure = ''
    cd python
  '';

  # No tests are included upstream
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "tinyobjloader" ];

  meta = tinyobjloader.meta // {
    description = "Python wrapper for the C++ wavefront .obj loader tinyobjloader";
  };
}
