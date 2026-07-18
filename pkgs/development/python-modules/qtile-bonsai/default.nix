{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cairocffi,
  cffi,
  psutil,
  pyside6,
  pytestCheckHook,
  pyvirtualdisplay,
  qtile,
  uv-build,
  xcffib,
}:
buildPythonPackage (finalAttrs: {
  pname = "qtile-bonsai";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "aravinda0";
    repo = "qtile-bonsai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JCElI4Ymr99p9dj++N9lyTFNmikntBwwImYREXFsUo0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'uv_build>=0.8.13,<0.9.0' 'uv_build'
  '';

  nativeCheckInputs = [
    pyside6
    pyvirtualdisplay
    (cairocffi.override { withXcffib = true; })
    cffi
    xcffib
    qtile
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [
    uv-build
  ];

  dependencies = [
    psutil
  ];

  disabledTestPaths = [
    # Needs a running DBUS
    "tests/integration/test_layout.py"
    "tests/integration/test_widget.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "qtile_bonsai" ];

  meta = {
    description = "Flexible layout for the qtile tiling window manager";
    homepage = "https://github.com/aravinda0/qtile-bonsai";
    changelog = "https://github.com/aravinda0/qtile-bonsai/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gurjaka
      sigmanificient
    ];
  };
})
