{
  lib,
  fetchFromSourcehut,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "lsplug";
  version = "7";

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "lsplug";
    tag = finalAttrs.version;
    hash = "sha256-eY9XNEdJfQREKroxsuPlv3CKqNX/XiMEnN8TdGYGa+g=";
  };

  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "lsplug"
  ];

  meta = {
    description = "Replacement for lsusb that shows more useful info and less useless info";
    homepage = "https://git.sr.ht/~martijnbraam/lsplug";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Luflosi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lsplug";
  };
})
