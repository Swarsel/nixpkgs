{
  lib,
  fetchFromGitHub,
  aiohttp,
  asn1,
  buildPythonPackage,
  python-dateutil,
  setuptools,
  tenacity,
}:

buildPythonPackage rec {
  pname = "smart-meter-texas";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "grahamwetzler";
    repo = "smart-meter-texas";
    tag = "v${version}";
    hash = "sha256-dHWcYrBtmKdEIU45rMy4KvoPX88hnRpd4KBlbJaNvgI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner" ""
  '';

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    asn1
    python-dateutil
    tenacity
  ];

  pyproject = true;

  meta = {
    description = "Connect to and retrieve data from the unofficial Smart Meter Texas API";
    homepage = "https://github.com/grahamwetzler/smart-meter-texas";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
