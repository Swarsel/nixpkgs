{
  lib,
  fetchFromGitHub,
  archinfo,
  buildPythonPackage,
  cart,
  cffi,
  nix-update-script,
  pefile,
  pyelftools,
  pytestCheckHook,
  pyvex,
  setuptools,
  sortedcontainers,
}:

let
  # The binaries are following the argr projects release cycle
  version = "9.2.154";

  # Binary files from https://github.com/angr/binaries (only used for testing and only here)
  binaries = fetchFromGitHub {
    hash = "sha256-XXJBySIT3ylK1nd3suP2bq4bVSVah/1XhOmkEONbCoY=";
    owner = "angr";
    repo = "binaries";
    tag = "v${version}";
  };
in
buildPythonPackage rec {
  inherit version;
  pname = "cle";

  src = fetchFromGitHub {
    owner = "angr";
    repo = "cle";
    tag = "v${version}";
    hash = "sha256-rWbZzm5hWi/C+te8zeQChxqYHO0S795tJ6Znocq9TTs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # Place test binaries in the right location (location is hard-coded in the tests)
  preCheck = ''
    export HOME=$TMPDIR
    cp -r ${binaries} $HOME/binaries
  '';

  build-system = [ setuptools ];

  dependencies = [
    archinfo
    cart
    cffi
    pefile
    pyelftools
    pyvex
    sortedcontainers
  ];

  disabledTests = [
    # PPC tests seems to fails
    "test_ppc_rel24_relocation"
    "test_ppc_addr16_ha_relocation"
    "test_ppc_addr16_lo_relocation"
    "test_plt_full_relro"
    # Test fails
    "test_tls_pe_incorrect_tls_data_start"
    "test_x86"
    "test_x86_64"
    # The required parts is not present on Nix
    "test_remote_file_map"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cle" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python loader for many binary formats";
    homepage = "https://github.com/angr/cle";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
