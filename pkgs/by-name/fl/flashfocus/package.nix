{
  lib,
  bash,
  fetchPypi,
  fetchpatch,
  netcat-openbsd,
  nix-update-script,
  procps,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "flashfocus";
  version = "2.4.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-O6jRQ6e96b8CuumTD6TGELaz26No7WFZgGSnNSlqzuE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-A7PwvqPpi4koKD3d6SRHVV753hGd9wIf3/nT49f6qoY=";
      name = "bump-marshmallow.patch";
      url = "https://github.com/fennerm/flashfocus/commit/0ed8616ad31c5e281be1a890ad9510323fa1b6c7.patch";
    })
  ];

  postPatch = ''
    substituteInPlace bin/nc_flash_window \
      --replace-fail "nc" "${lib.getExe netcat-openbsd}"

    substituteInPlace src/flashfocus/util.py \
      --replace-fail "pidof" "${lib.getExe' procps "pidof"}"
  '';

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  buildInputs = [
    bash
  ];

  propagatedBuildInputs = with python3Packages; [
    i3ipc
    xcffib
    click
    cffi
    xpybutil
    marshmallow
    pyyaml
  ];

  # Tests require access to a X session
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "flashfocus" ];

  pythonRelaxDeps = [
    "pyyaml"
    "xcffib"
    "cffi"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple focus animations for tiling window managers";
    homepage = "https://github.com/fennerm/flashfocus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
  };
})
