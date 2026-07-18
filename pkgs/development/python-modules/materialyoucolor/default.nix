{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  psutil,
  pybind11,
  rich,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "materialyoucolor";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "T-Dynamos";
    repo = "materialyoucolor-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CCpYrNp79gdnj5TYcQ7fEiLsFW/kbuZ+3/cHZF4Bv/s=";
  };

  nativeCheckInputs = [
    psutil
    rich
  ];

  checkPhase = ''
    runHook preCheck

    # test script taken from .github/workflows/cibuildwheel.yml
    python -c "from PIL import Image; Image.new('RGB', (128, 128), (70, 120, 180)).save('test_image.jpg')"
    python tests/test_all.py --image test_image.jpg --quality 1 --method pillow --tonal-spot
    python tests/test_all.py --image test_image.jpg --quality 1 --method cpp --tonal-spot

    runHook postCheck
  '';

  build-system = [
    setuptools
    pybind11
  ];

  dependencies = [
    pillow
  ];

  pyproject = true;

  pythonImportsCheck = [
    "materialyoucolor"
    "materialyoucolor.quantize" # ext
  ];

  meta = {
    description = "Material You color generation algorithms in python";
    homepage = "https://github.com/T-Dynamos/materialyoucolor-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
