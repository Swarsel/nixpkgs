{
  lib,
  stdenv,
  # dependencies
  altgraph,
  # tests
  binutils,
  buildPythonPackage,
  fetchPypi,
  glibc,
  # build-system
  hatchling,
  macholib,
  packaging,
  pyinstaller,
  pyinstaller-hooks-contrib,
  testers,
  # native dependencies
  zlib,
}:

buildPythonPackage rec {
  pname = "pyinstaller";
  version = "6.18.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zcUHVCeDURytSFb85YL9w36fKWZcpZaInGY8g+yMbsk=";
  };

  buildInputs = [ zlib.dev ];
  build-system = [ hatchling ];

  dependencies = [
    altgraph
    packaging
    macholib
    pyinstaller-hooks-contrib
  ];

  makeWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      glibc
      binutils
    ])
  ];

  pyproject = true;
  pythonImportsCheck = [ "PyInstaller" ];

  passthru.tests.version = testers.testVersion {
    package = pyinstaller;
  };

  meta = {
    description = "Tool to bundle a python application with dependencies into a single package";
    homepage = "https://pyinstaller.org/";
    changelog = "https://pyinstaller.org/en/v${version}/CHANGES.html";

    license = with lib.licenses; [
      mit
      asl20
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ h7x4 ];
    mainProgram = "pyinstaller";
    downloadPage = "https://pypi.org/project/pyinstaller/";
  };
}
