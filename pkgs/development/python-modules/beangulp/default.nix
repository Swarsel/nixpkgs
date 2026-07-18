{
  lib,
  fetchFromGitHub,
  beancount,
  beautifulsoup4,
  buildPythonPackage,
  chardet,
  click,
  fetchpatch2,
  lxml,
  petl,
  pytestCheckHook,
  python-magic,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "beangulp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "beancount";
    repo = "beangulp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h7xLHwEyS+tOI7v6Erp12VfVnxOf4930++zghhC3in4=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-ojysT23K0xmFafzTnRZiHkLS2ioDR/tVK02mfF7N9so=";
      url = "https://github.com/beancount/beangulp/commit/254bfb38ffed049ef8f3041bfaf01b3f5a8aa771.patch?full_index=1";
    })
  ];

  nativeCheckInputs = [
    petl
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    beancount
    beautifulsoup4
    chardet
    click
    lxml
    python-magic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "beangulp"
  ];

  meta = {
    description = "Importers framework for Beancount";

    longDescription = ''
      Beangulp provides a framework for importing transactions into a Beancoount
      ledger from account statements and other documents and for managing documents.
    '';

    homepage = "https://github.com/beancount/beangulp";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ alapshin ];
  };
})
