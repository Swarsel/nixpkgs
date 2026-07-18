{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "djhtml";
  version = "3.0.11";

  src = fetchFromGitHub {
    owner = "rtts";
    repo = "djhtml";
    tag = finalAttrs.version;
    hash = "sha256-l3qxPwnEyJ0sZWquaol0bOX7QvImLc8IRTfyE2yqXCo=";
  };

  build-system = [ python3Packages.setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "djhtml" ];

  meta = {
    description = "Django/Jinja template indenter";
    homepage = "https://github.com/rtts/djhtml";
    changelog = "https://github.com/rtts/djhtml/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "djhtml";
  };
})
