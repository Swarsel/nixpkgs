{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyluwen,
  # tests
  pytestCheckHook,
  # dependencies
  pyyaml,
  # build-system
  setuptools,
  tabulate,
  tt-tools-common,
}:
buildPythonPackage (finalAttrs: {
  pname = "tt-flash";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-flash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wE8qDgoXiYeUbrcGY46JnPVT4neNGu3U5DTXlMuewjc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    tabulate
    pyyaml
    pyluwen
    tt-tools-common
  ];

  pyproject = true;
  pythonImportsCheck = [ "tt_flash" ];

  pythonRelaxDeps = [
    "pyyaml"
    "tabulate"
  ];

  meta = {
    description = "Tenstorrent Firmware Update Utility";
    homepage = "https://tenstorrent.com";
    changelog = "https://github.com/tenstorrent/tt-flash/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    downloadPage = "https://github.com/tenstorrent/tt-flash";
  };
})
