{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  pymodbus,
  pyserial-asyncio,
  pytest-asyncio,
  pytestCheckHook,
  pyusb,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-dali";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "sde1000";
    repo = "python-dali";
    tag = "v${version}";
    hash = "sha256-F/D0wyMVCUaL2SCdPKvnGS22tSgDnvUh6rs2ToKON2c=";
  };

  patches = [
    # pymodbus 3.x support
    (fetchpatch {
      hash = "sha256-bcfr948g7M6m3AQVArcYw9a22jA5eMim+J58iKci55s=";
      url = "https://github.com/sde1000/python-dali/commit/fe85b8fd9a746d16a03de8fd8c643ef4254d1ccd.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  optional-dependencies = {
    driver-serial = [ pyserial-asyncio ];

    driver-unipi = [
      pyusb
      pymodbus
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dali" ];

  meta = {
    description = "IEC 62386 (DALI) lighting control library";
    homepage = "https://github.com/sde1000/python-dali";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ sikmir ];
  };
}
