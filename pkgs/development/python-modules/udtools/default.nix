{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  python,
  # dependencies
  regex,
  setuptools,
  udapi,
}:

buildPythonPackage (finalAttrs: {
  pname = "udtools";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "UniversalDependencies";
    repo = "tools";
    tag = "py${finalAttrs.version}";
    hash = "sha256-PeMIjxHU99HHNwT/D6UiS5HqxXj66ngRTYfA1xn9uOw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    install -dm755 $out/${python.sitePackages}/udtools/data
    cp $src/data/* $out/${python.sitePackages}/udtools/data
  '';

  build-system = [ setuptools ];

  dependencies = [
    udapi
    regex
  ];

  pyproject = true;
  pythonImportsCheck = [ "udtools" ];
  sourceRoot = "${finalAttrs.src.name}/udtools";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=py(.*)" ];
  };

  meta = {
    description = "Python tools for Universal Dependencies";
    homepage = "https://universaldependencies.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Stebalien
    ];
  };
})
