{
  lib,
  fetchFromGitHub,
  python3Packages,
  sbom2dot,
  sbom4files,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sbom4python";
  version = "0.12.6";

  src = fetchFromGitHub {
    owner = "anthonyharrison";
    repo = "sbom4python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-205QuBzO5ABxAh4p+yIs5mLbQENIr1K3GohTlYqReuQ=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    importlib-metadata
    lib4package
    lib4sbom
    sbom2dot
    sbom4files
    setuptools # for pkg_resources
    toml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sbom4python"
  ];

  meta = {
    description = "Tool to generate a SBOM (Software Bill of Materials) for an installed Python module";
    homepage = "https://github.com/anthonyharrison/sbom4python";
    changelog = "https://github.com/anthonyharrison/sbom4python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "sbom4python";
  };
})
