{
  lib,
  aioquic,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  h2,
  hatchling,
  httpcore,
  httpx,
  idna,
  pytestCheckHook,
  trio,
}:

buildPythonPackage rec {
  pname = "dnspython";
  version = "2.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-GB08aZZFLLEYnEBGxhWZuEpahuCZVi/9530mmE/ybQ8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # disable network on all builds (including darwin)
  # see https://github.com/NixOS/nixpkgs/issues/356803
  preCheck = ''
    export NO_INTERNET=1
  '';

  build-system = [ hatchling ];

  disabledTests = [
    # dns.exception.SyntaxError: protocol not found
    "test_misc_good_WKS_text"
  ];

  optional-dependencies = {
    dnssec = [ cryptography ];

    doh = [
      httpx
      h2
      httpcore
    ];

    doq = [ aioquic ];
    idna = [ idna ];
    trio = [ trio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dns" ];

  meta = {
    description = "DNS toolkit for Python";
    homepage = "https://www.dnspython.org";
    changelog = "https://github.com/rthalley/dnspython/blob/v${version}/doc/whatsnew.rst";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ gador ];
  };
}
