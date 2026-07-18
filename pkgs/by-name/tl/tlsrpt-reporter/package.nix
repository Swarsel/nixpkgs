{
  lib,
  fetchFromGitHub,
  asciidoctor,
  automake,
  fetchpatch,
  installShellFiles,
  nixosTests,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "tlsrpt-reporter";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "sys4";
    repo = "tlsrpt-reporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IH8hJX9l+YonqOuszcMome4mjdIaedgGNIptxTyH1ng=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-RUNF86RkTu6DLv6/7eaY//fFB8kGzmZxQ70kdNpLxj8=";
      # https://github.com/sys4/tlsrpt-reporter/issues/43
      url = "https://github.com/sys4/tlsrpt-reporter/commit/32d00c13508dd7f9695b77e253e88c88dc838fbd.patch";
    })
    # https://github.com/sys4/tlsrpt-reporter/pull/48
    ./logging.patch
  ];

  nativeBuildInputs = [
    asciidoctor
    automake
    installShellFiles
  ];

  postBuild = ''
    make -C doc
  '';

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  postInstall = ''
    installManPage doc/*.1
  '';

  build-system = [
    python3.pkgs.hatchling
  ];

  disabledTests = [
    # argparse string matching offset since py314
    "test_b0rkcmd"
    "test_intarg_cmd_float"
    "test_intarg_cmd_string"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tlsrpt_reporter"
  ];

  passthru.tests = {
    inherit (nixosTests) tlsrpt;
  };

  meta = {
    description = "Application suite to receive TLSRPT datagrams and to generate and deliver TLSRPT reports";
    homepage = "https://github.com/sys4/tlsrpt-reporter";
    changelog = "https://github.com/sys4/tlsrpt-reporter/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
