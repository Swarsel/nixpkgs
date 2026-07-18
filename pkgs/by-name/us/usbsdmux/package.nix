{
  lib,
  fetchPypi,
  python3Packages,
  udevCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "usbsdmux";
  version = "25.8";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-/hDDEUvpdpUpg3ZVw8NWcDOLOtLu087Ki7FmGrDh9Gg=";
  };

  # Remove the wrong GROUP=plugdev.
  # The udev rule already has TAG+="uaccess", which is sufficient.
  postPatch = ''
    substituteInPlace contrib/udev/99-usbsdmux.rules \
      --replace-fail 'TAG+="uaccess", GROUP="plugdev"' 'TAG+="uaccess"'
  '';

  nativeBuildInputs = [
    udevCheckHook
  ];

  postInstall = ''
    install -Dm0444 -t $out/lib/udev/rules.d/ contrib/udev/99-usbsdmux.rules
  '';

  doInstallCheck = true;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "usbsdmux" ];

  meta = {
    description = "Control software for the LXA USB-SD-Mux";
    homepage = "https://github.com/linux-automation/usbsdmux";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; linux;
  };
})
