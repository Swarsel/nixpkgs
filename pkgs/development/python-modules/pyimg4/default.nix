{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-compress,
  asn1,
  buildPythonPackage,
  click,
  hatchling,
  lzfse,
  pycryptodome,
  pylzss,
  pytestCheckHook,
  remotezip,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "pyimg4";
  version = "0.8.8";

  src = fetchFromGitHub {
    owner = "m1stadev";
    repo = "PyIMG4";
    tag = "v${version}";
    hash = "sha256-rGFHd4MAJrbKhtX+Ey/zqQ/12wWxDyBBy1xPGDFQjao=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    remotezip
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    asn1
    click
    pycryptodome
    pylzss
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-compress
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    lzfse
  ];

  disabledTests = [
    # tests take forever
    "test_read_lzss_dec"
    "test_read_lzss_enc"
    "test_read_lzfse_dec"
    "test_read_lzfse_enc"
    "test_read_payp"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyimg4" ];

  pythonRelaxDeps = [
    "pylzss"
  ];

  meta = {
    description = "Python library/CLI tool for parsing Apple's Image4 format";
    homepage = "https://github.com/m1stadev/PyIMG4";
    changelog = "https://github.com/m1stadev/PyIMG4/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "pyimg4";
    # https://github.com/m1stadev/PyIMG4/pull/59
    broken = lib.versionAtLeast asn1.version "3";
  };
}
