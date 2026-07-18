{
  lib,
  stdenv,
  buildPythonPackage,
  click,
  colorama,
  fetchPypi,
  gitMinimal,
  gnugrep,
  gnupg,
  pbr,
  pexpect,
  pytestCheckHook,
  replaceVars,
  setuptools,
  tree,
  xclip,
}:

# Use the `pypass` top-level attribute, if you're interested in the
# application
buildPythonPackage (finalAttrs: {
  pname = "pypass";
  version = "0.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+dAQiufpULdU26or4EKDqazQbOZjGRbhI/+ddo+spNo=";
  };

  # Set absolute nix store paths to the executables that pypass uses
  patches = [
    (replaceVars ./mark-executables.patch {
      git_exec = "${gitMinimal}/bin/git";
      gpg_exec = "${gnupg}/bin/gpg2";
      grep_exec = "${gnugrep}/bin/grep";
      tree_exec = "${tree}/bin/tree";
      xclip_exec = "${xclip}/bin/xclip";
    })
  ];

  nativeBuildInputs = [ pbr ];

  nativeCheckInputs = [
    gitMinimal
    pytestCheckHook
  ];

  # Configuration so that the tests work
  preCheck = ''
    export HOME=$(mktemp -d)
    export GNUPGHOME=pypass/tests/gnupg
    git config --global user.email "nix-builder@nixos.org"
    git config --global user.name "Nix Builder"
    git config --global pull.ff only
    make setup_gpg
  '';

  build-system = [ setuptools ];

  dependencies = [
    click
    colorama
    pexpect
  ];

  # Presumably this test needs the X clipboard, which we don't have
  # as the test environment is non-graphical.
  disabledTests = [ "test_show_clip" ];
  pyproject = true;

  pythonRemoveDeps = [
    "enum34"
  ];

  meta = {
    description = "Password manager pass in Python";
    homepage = "https://github.com/aviau/python-pass";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jluttine ];
    platforms = lib.platforms.all;
    mainProgram = "pypass";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
