{
  lib,
  buildPythonPackage,
  fetchPypi,
  pillow,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aafigure";
  version = "0.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-SfLB/StXnB//usE4aiZws/b0dcx/9swE2LmEiIwtnh4=";
  };

  propagatedBuildInputs = [ pillow ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  # Fix impurity. TODO: Do the font lookup using fontconfig instead of this
  # manual method. Until that is fixed, we get this whenever we run aafigure:
  #   WARNING: font not found, using PIL default font
  patchPhase = ''
    sed -i "s|/usr/share/fonts|/nonexisting-fonts-path|" aafigure/PILhelper.py
  '';

  pyproject = true;

  meta = {
    description = "ASCII art to image converter";
    homepage = "https://launchpad.net/aafigure/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.unix;
    mainProgram = "aafigure";
  };
})
