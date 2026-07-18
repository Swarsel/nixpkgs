{
  lib,
  fetchFromGitHub,
  # dependencies
  asn1crypto,
  bincopy,
  bitstring,
  buildPythonPackage,
  chardet,
  click,
  click-command-tree,
  click-option-group,
  colorama,
  # tests
  cookiecutter,
  crcmod,
  cryptography,
  deepmerge,
  fastjsonschema,
  filelock,
  hexdump,
  ipykernel,
  libusbsio,
  libuuu,
  oscrypto,
  packaging,
  platformdirs,
  prettytable,
  pyasn1,
  pyocd,
  pyserial,
  pytest-notebook,
  pytestCheckHook,
  requests,
  ruamel-yaml,
  # build-system
  setuptools,
  setuptools-scm,
  sly,
  spsdk-mcu-link,
  spsdk-pyocd,
  typing-extensions,
  versionCheckHook,
  voluptuous,
  writableTmpDirAsHomeHook,
  x690,
}:

buildPythonPackage (finalAttrs: {
  pname = "spsdk";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "nxp-mcuxpresso";
    repo = "spsdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eA18DvQ0IIZtseJXXXMiFYkaOwBIhVXNaWiAObIj55I=";
  };

  nativeCheckInputs = [
    cookiecutter
    ipykernel
    pytest-notebook
    pytestCheckHook
    voluptuous
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asn1crypto
    bincopy
    bitstring
    chardet
    click
    click-command-tree
    click-option-group
    colorama
    cookiecutter
    crcmod
    cryptography
    deepmerge
    fastjsonschema
    filelock
    hexdump
    libusbsio
    libuuu
    oscrypto
    packaging
    platformdirs
    prettytable
    pyasn1
    pyocd
    pyserial
    requests
    ruamel-yaml
    sly
    spsdk-mcu-link
    spsdk-pyocd
    typing-extensions
    x690
  ];

  disabledTests = [
    # Missing rotk private key
    "test_general_notebooks"

    # Attempts to access /run
    "test_nxpimage_famode_export_cli"

    # spsdk.exceptions.SPSDKValueError: SPSDK: The EC curve with name 'sect163k1' is not supported
    "test_keys_generation_ec"
  ];

  pyproject = true;
  pythonImportsCheck = [ "spsdk" ];

  pythonRelaxDeps = [
    "cryptography"
    "filelock"
    "importlib-metadata"
    "packaging"
    "prettytable"
    "requests"
    "ruamel.yaml.clib"
    "setuptools_scm"
    "typing-extensions"
  ];

  pythonRemoveDeps = [
    # Remove unneeded unfree package. pyocd-pemicro is only used when
    # generating a pyinstaller package, which we don't do.
    "pyocd-pemicro"
  ];

  meta = {
    description = "NXP Secure Provisioning SDK";
    homepage = "https://github.com/nxp-mcuxpresso/spsdk";
    changelog = "https://github.com/nxp-mcuxpresso/spsdk/blob/${finalAttrs.src.tag}/docs/release_notes.rst";
    license = lib.licenses.bsd3;

    maintainers = [
    ];

    mainProgram = "spsdk";
  };
})
