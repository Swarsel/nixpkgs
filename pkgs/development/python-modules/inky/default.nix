{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gpiodevice,
  hatch-fancy-pypi-readme,
  hatch-requirements-txt,
  hatchling,
  numpy,
  pillow,
  pytestCheckHook,
  python,
  smbus2,
  spidev,
}:
buildPythonPackage (finalAttrs: {
  pname = "inky";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "pimoroni";
    repo = "inky";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wHAAfTAJ0MEmGrZypH/YOkyMzC+sav8fBEXnk/Q2ed0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # The build explicitly copies over these docs files, which cause collisions with other pimoroni repos.
  # Preserve the files (especially license), but move elsewhere.
  postInstall = ''
    mkdir -p $out/share/doc/${finalAttrs.pname}
    mkdir -p $out/share/licenses/${finalAttrs.pname}

    mv "$out/${python.sitePackages}/LICENSE" $out/share/licenses/${finalAttrs.pname}/
    mv "$out/${python.sitePackages}/README.md" $out/share/doc/${finalAttrs.pname}/
    mv "$out/${python.sitePackages}/CHANGELOG.md" $out/share/doc/${finalAttrs.pname}/
  '';

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
    hatch-requirements-txt
  ];

  dependencies = [
    numpy
    pillow
    smbus2
    spidev
    gpiodevice
  ];

  pyproject = true;
  pythonImportsCheck = [ "inky" ];

  meta = {
    description = "Python library for Inky pHAT, Inky wHAT and Inky Impression e-paper displays for Raspberry Pi.";
    homepage = "https://github.com/pimoroni/inky";
    changelog = "https://github.com/pimoroni/inky/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ theconcierge ];
  };
})
