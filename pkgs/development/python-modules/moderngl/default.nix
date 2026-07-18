{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  glcontext,
  libGL,
  libx11,
  pkgs,
  setuptools,
}:

buildPythonPackage rec {
  pname = "moderngl";
  version = "5.12.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UpNqmMyy8uHW48sYUospGfaDHn4/kk54i1hzutzlEps=";
  };

  postPatch = lib.optionalString (stdenv.hostPlatform.isLinux) ''
    substituteInPlace _moderngl.py \
      --replace-fail '"libGL.so"' '"${libGL}/lib/libGL.so"' \
      --replace-fail '"libEGL.so"' '"${libGL}/lib/libEGL.so"'
  '';

  buildInputs = lib.optionals (stdenv.hostPlatform.isLinux) [
    libGL
    libx11
  ];

  # Tests need a display to run.
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ glcontext ];
  pyproject = true;
  pythonImportsCheck = [ "moderngl" ];

  meta = {
    inherit (pkgs.mesa.meta) platforms;
    description = "High performance rendering for Python";
    homepage = "https://github.com/moderngl/moderngl";
    changelog = "https://github.com/moderngl/moderngl/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ c0deaddict ];
  };
}
