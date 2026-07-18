{
  lib,
  cyclonedx-python,
  fetchFromGitea,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sbom-compliance-tool";
  version = "0.0.11";

  src = fetchFromGitea {
    owner = "software-compliance-org";
    repo = "sbom-compliance-tool";
    tag = finalAttrs.version;
    hash = "sha256-6ZaHY1EKjJ78PrCov0wenj5doc93Ot9/yN4hEaagSmE=";
    domain = "codeberg.org";
  };

  postPatch = ''
    # https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#finding-namespace-packages
    substituteInPlace setup.py \
      --replace-fail \
        "packages=['sbom_compliance_tool']" \
        "packages=setuptools.find_namespace_packages(include=['sbom_compliance_tool*'])"
  '';

  # upstream has no tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    cyclonedx-python
    foss-flame
    licomp
    licomp-toolkit
    lookup-license
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sbom_compliance_tool"
    "sbom_compliance_tool.reader"
  ];

  meta = {
    description = "Tool to assist your compliance work with SBoM";
    homepage = "https://codeberg.org/software-compliance-org/sbom-compliance-tool";

    license = with lib.licenses; [
      gpl3Only
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "sbom_compliance_tool";
    teams = with lib.teams; [ ngi ];
  };
})
