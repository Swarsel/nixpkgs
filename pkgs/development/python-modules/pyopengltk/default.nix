{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pyopengl,
  setuptools,
  tkinter,
  writers,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyopengltk";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "jonwright";
    repo = "pyopengltk";
    rev = "dbed7b7d01cc5a90fd3e79769259b1dc0894b673"; # there is no tag
    hash = "sha256-hQoTj8h/L5VZgmq7qgRImLBKZMecrilyir5Ar6ne4S0=";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyopengl
    tkinter
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyopengltk" ];

  passthru.tests = {
    cube = writers.writePython3 "cube" {
      doCheck = false;
      libraries = [ finalAttrs.finalPackage ];
    } (builtins.readFile "${finalAttrs.src}/examples/cube.py");
  };

  meta = {
    description = "OpenGL frame for Python/Tkinter via ctypes and pyopengl";
    homepage = "https://github.com/jonwright/pyopengltk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    # not supported yet, see: https://github.com/jonwright/pyopengltk/issues/12
    broken = stdenv.hostPlatform.isDarwin;
  };
})
