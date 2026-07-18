{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "tockloader";
  version = "1.9.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-7W55jugVtamFUL8N3dD1LFLJP2UDQb74V6o96rd/tEg=";
  };

  # Project has no test suite
  checkPhase = ''
    runHook preCheck
    $out/bin/tockloader --version | grep -q ${finalAttrs.version}
    runHook postCheck
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    argcomplete
    colorama
    crcmod
    pycryptodome
    pyserial
    questionary
    toml
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "tockloader" ];

  meta = {
    description = "Tool for programming Tock onto hardware boards";
    homepage = "https://github.com/tock/tockloader";
    changelog = "https://github.com/tock/tockloader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "tockloader";
  };
})
