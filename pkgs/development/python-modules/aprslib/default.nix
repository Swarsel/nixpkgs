{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aprslib";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "rossengeorgiev";
    repo = "aprs-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2bYTnbJ8wF/smTpZ2tV+3ZRae7FpbNBtXoaR2Sc9Pek=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-uxiLIagz1PIUUa6/qdBW15yhm/0QXqznVzZnzUVCWuQ=";
      url = "https://github.com/rossengeorgiev/aprs-python/commit/c2a0f18ce028a4cced582567a73d57f0d03cd00f.patch";
    })
  ];

  doCheck = false; # mox3 is not packaged
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "aprslib" ];

  meta = {
    description = "Module for accessing APRS-IS and parsing APRS packets";
    homepage = "https://github.com/rossengeorgiev/aprs-python";
    changelog = "https://github.com/rossengeorgiev/aprs-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
