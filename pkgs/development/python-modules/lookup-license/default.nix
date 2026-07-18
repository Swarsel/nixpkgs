{
  lib,
  fetchFromGitHub,
  # dependencies
  appdirs,
  buildPythonPackage,
  cachetools,
  diskcache,
  foss-flame,
  license-expression,
  packageurl-python,
  # tests
  pytestCheckHook,
  python-magic,
  requests,
  scancode-toolkit,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "lookup-license";
  version = "0.1.30";

  src = fetchFromGitHub {
    owner = "hesa";
    repo = "lookup-license";
    tag = finalAttrs.version;
    hash = "sha256-zFDqh62bjYkO3Duze3suS8LlrlzuqQes7ZaH+9G+yQ4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    appdirs
    cachetools
    diskcache
    foss-flame
    license-expression
    packageurl-python
    python-magic
    requests
    scancode-toolkit
    xmltodict
  ];

  disabledTests = [
    # UnboundLocalError: cannot access local variable 'ret' where it is not associated with a value
    "test_lookup_license_url_bad"
    "test_lookup_license_url_good"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "lookup_license"
  ];

  pythonRelaxDeps = [
    "requests"
  ];

  meta = {
    description = "Python tool to identify license from license text";
    homepage = "https://github.com/hesa/lookup-license";
    changelog = "https://github.com/hesa/lookup-license/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl3Only
      asl20
      cc-by-40
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "lookup-license";
    teams = with lib.teams; [ ngi ];
  };
})
