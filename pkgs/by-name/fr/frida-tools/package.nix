{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "frida-tools";
  version = "14.10.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-eixUS1RdCVBA//vTdoooekJjQ9rYkJW0ok9LIDgtkmo=";
    pname = "frida_tools";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pygments
    prompt-toolkit
    colorama
    frida-python
    websockets
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "frida"
    "websockets"
  ];

  meta = {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers (client tools)";
    homepage = "https://www.frida.re/";

    license = with lib.licenses; [
      lgpl2Plus
      wxWindowsException31
    ];

    maintainers = with lib.maintainers; [
      s1341
      eyjhb
    ];
  };
})
