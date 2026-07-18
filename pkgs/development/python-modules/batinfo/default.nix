{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "batinfo";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "nicolargo";
    repo = "batinfo";
    tag = "v${version}";
    hash = "sha256-GgAJJA8bzQJLAU+nxmkDa5LFTHc4NGi+nj9PfKyw8/M=";
  };

  postPatch = ''
    substituteInPlace test_batinfo.py \
      --replace-fail "self.assertEquals" "self.assertEqual"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # Tests are a bit outdated
    "test_batinfo_capacity"
    "test_batinfo_charge_now"
    "test_batinfo_name_default"
  ];

  pyproject = true;
  pythonImportsCheck = [ "batinfo" ];

  passthru = {
    # Upstream has a broken 2.0 tag that causes this package to get downgraded to 0.2
    skipBulkUpdate = true;
  };

  meta = {
    description = "Module to retrieve battery information";
    homepage = "https://github.com/nicolargo/batinfo";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ koral ];
    platforms = lib.platforms.linux;
  };
}
