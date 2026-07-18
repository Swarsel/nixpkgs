{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  meson-python,
  nix-update-script,
  pkg-config,
  pytestCheckHook,
  versioningit,
}:

buildPythonPackage rec {
  pname = "uarray";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "Quansight-Labs";
    repo = "uarray";
    tag = version;
    hash = "sha256-Jut/V0/na+dcVpD7buW0DIS+KpA+dGRRb6QpPDt2/hY=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  preBuild = ''
    echo "__version__ = '$version'" > src/uarray/_version.py
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    meson-python
    versioningit
  ];

  pyproject = true;

  pytestFlags = [
    "--pyargs"
    "uarray"
  ];

  pythonImportsCheck = [ "uarray" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal array library";
    homepage = "https://github.com/Quansight-Labs/uarray";
    changelog = "https://github.com/Quansight-Labs/uarray/releases/tag/${src.tag}";
    license = lib.licenses.bsd0;
    maintainers = [ lib.maintainers.pbsds ];
  };
}
