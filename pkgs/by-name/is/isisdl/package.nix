{
  lib,
  fetchPypi,
  python3Packages,
  util-linux,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "isisdl";
  version = "1.3.21";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-YyR0A7NqmUcR+hQnQlIgBdU6CxfHtDOjR3q5I21ROCI=";
  };

  buildInputs = [
    util-linux # for runtime dependency `lsblk`
  ];

  # disable tests since they require valid login credentials
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    cryptography
    requests
    pyyaml
    packaging
    colorama
    pyinotify
    distro
    psutil
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "cryptography"
    "requests"
    "packaging"
    "distro"
    "psutil"
  ];

  meta = {
    description = "Downloader for ISIS of TU-Berlin";

    longDescription = ''
      A downloading utility for ISIS of TU-Berlin.
      Download all your files and videos from ISIS.
    '';

    homepage = "https://github.com/Emily3403/isisdl";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ bchmnn ];
    platforms = lib.platforms.linux;
    mainProgram = "isisdl";
  };
})
