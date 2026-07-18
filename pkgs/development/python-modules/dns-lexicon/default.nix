{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  boto3,
  buildPythonPackage,
  cryptography,
  dnspython,
  localzone,
  oci,
  poetry-core,
  pyotp,
  pytest-vcr,
  pytestCheckHook,
  pyyaml,
  requests,
  softlayer,
  tldextract,
  zeep,
}:

buildPythonPackage rec {
  pname = "dns_lexicon";
  version = "3.16.1";

  src = fetchFromGitHub {
    owner = "Analogj";
    repo = "lexicon";
    tag = "v${version}";
    hash = "sha256-79/zz0TOCpx26TEo6gi9JDBQeVW2azWnxAjWr/FGRLA=";
  };

  # https://beautiful-soup-4.readthedocs.io/en/latest/#method-names
  postPatch = ''
    sed 's/\<findAll\>/find_all/g' \
      -i src/lexicon/_private/providers/*.py
    sed 's/\<renderContents\>/encode_contents/g' \
      -i src/lexicon/_private/providers/*.py
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    beautifulsoup4
    cryptography
    pyotp
    pyyaml
    requests
    tldextract
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-vcr
  ]
  ++ optional-dependencies.full;

  disabledTestPaths = [
    # Needs network access
    "tests/providers/test_auto.py"
    # Needs network access (and an API token)
    "tests/providers/test_namecheap.py"
  ];

  disabledTests = [
    # Tests want to download Public Suffix List
    "test_client_legacy_init"
    "test_client_basic_init"
    "test_client_init"
    "test_client_parse_env"
    "test_missing"
    "action_is_correctly"
  ];

  enabledTestPaths = [ "tests/" ];

  optional-dependencies = {
    ddns = [ dnspython ];
    duckdns = [ dnspython ];

    full = [
      boto3
      dnspython
      localzone
      oci
      softlayer
      zeep
    ];

    localzone = [ localzone ];
    oci = [ oci ];
    route53 = [ boto3 ];
    softlayer = [ softlayer ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lexicon" ];

  meta = {
    description = "Manipulate DNS records on various DNS providers in a standardized way";
    homepage = "https://github.com/AnalogJ/lexicon";
    changelog = "https://github.com/AnalogJ/lexicon/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ aviallon ];
    mainProgram = "lexicon";
  };
}
