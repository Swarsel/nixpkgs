{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  gcc,
  glfw3,
  libffi,
  physac,
  pkg-config,
  raygui,
  raylib,
  setuptools,
  writers,
}:

buildPythonPackage (finalAttrs: {
  pname = "raylib-python-cffi";
  version = "6.0.1.0";

  src = fetchFromGitHub {
    owner = "electronstudio";
    repo = "raylib-python-cffi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9eN3H62gYDloMHbJbTFiO3acif3GJuTkk4CWltzBOXg=";
  };

  patches = [ ./use-direct-pkg-config-name.patch ];

  nativeBuildInputs = [
    pkg-config
    gcc
  ];

  buildInputs = [
    glfw3
    libffi
    raylib
    physac
    raygui
  ];

  # tests require a graphic environment
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "pyray" ];

  passthru.tests = import ./passthru-tests.nix {
    inherit writers;
    raylib-python-cffi = finalAttrs.finalPackage;
  };

  meta = {
    description = "Python CFFI bindings for Raylib";
    homepage = "https://electronstudio.github.io/raylib-python-cffi";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
