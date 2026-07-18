{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  flit-core,
  pytestCheckHook,
}:

let
  pname = "socksio";
  version = "1.0.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+IvrPaW1w4uYkEad5n0MsPnUlLeLEGyhhF+WwQuRxKw=";
  };

  patches = [
    # https://github.com/sethmlarson/socksio/pull/61
    (fetchpatch {
      hash = "sha256-VVUzFvF2KCXXkCfCU5xu9acT6OLr+PlQQPeVGONtU4A=";
      name = "unpin-flit-core.patch";
      url = "https://github.com/sethmlarson/socksio/commit/5c50fd76e7459bb822ff8f712172a78e21b8dd04.patch";
    })
  ];

  nativeBuildInputs = [ flit-core ];
  nativeCheckInputs = [ pytestCheckHook ];

  # remove coverage configuration
  preCheck = ''
    rm pytest.ini
  '';

  pyproject = true;

  meta = {
    description = "Sans-I/O implementation of SOCKS4, SOCKS4A, and SOCKS5";
    homepage = "https://github.com/sethmlarson/socksio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
