{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipython,
  numpy,
  pillow,
  pyngrok,
  pyzmq,
  tornado,
  u-msgpack-python,
}:

buildPythonPackage (finalAttrs: {
  pname = "meshcat";
  version = "0.3.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-LP4XzeT+hdByo94Bip2r9WJvgMJV//LOY7JqSNJIStk=";
  };

  postPatch = ''
    sed -i '/PYTHONPATH/d' src/meshcat/servers/zmqserver.py
  '';

  propagatedBuildInputs = [
    ipython
    u-msgpack-python
    numpy
    tornado
    pyzmq
    pyngrok
    pillow
  ];

  # requires a running MeshCat viewer
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "meshcat" ];

  meta = {
    description = "WebGL-based 3D visualizer for Python";
    homepage = "https://github.com/rdeits/meshcat-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "meshcat-server";
  };
})
