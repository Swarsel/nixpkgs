{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  busybox,
  pyinstaller,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "isocodes";
  version = "2025.8.25";

  src = fetchFromGitHub {
    owner = "Atem18";
    repo = "isocodes";
    tag = finalAttrs.version;
    hash = "sha256-rGARvUNaTZ8/CuQ2vhPRx4whYty8lJLSE+5AZTS3eQw=";
  };

  nativeCheckInputs = [
    pyinstaller
    pytestCheckHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    busybox
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "isocodes" ];

  meta = {
    description = "This project provides lists of various ISO standards (e.g. country, language, language scripts, and currency names) in one place";
    homepage = "https://github.com/Atem18/isocodes";
    changelog = "https://github.com/Atem18/isocodes/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      gigahawk
    ];
  };
})
