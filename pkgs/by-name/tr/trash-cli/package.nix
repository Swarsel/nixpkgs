{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trash-cli";
  version = "0.24.5.26";

  src = fetchFromGitHub {
    owner = "andreafrancia";
    repo = "trash-cli";
    rev = finalAttrs.version;
    hash = "sha256-ltuMnxtG4jTTSZd6ZHWl8wI0oQMMFqW0HAPetZMfGtc=";
  };

  postPatch = ''
    sed -i '/typing/d' setup.cfg
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = with python3Packages; [
    mock
    pytestCheckHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for bin in trash-empty trash-list trash-restore trash-put trash; do
      installShellCompletion --cmd "$bin" \
        --bash <("$out/bin/$bin" --print-completion bash) \
        --zsh  <("$out/bin/$bin" --print-completion zsh)
    done
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    # Create a home directory with a test file.
    HOME="$(mktemp -d)"
    touch "$HOME/deleteme"

    # Verify that trash list is initially empty.
    [[ $($out/bin/trash-list) == "" ]]

    # Trash a test file and verify that it shows up in the list.
    $out/bin/trash "$HOME/deleteme"
    [[ $($out/bin/trash-list) == *" $HOME/deleteme" ]]

    # Empty the trash and verify that it is empty.
    $out/bin/trash-empty
    [[ $($out/bin/trash-list) == "" ]]

    runHook postInstallCheck
  '';

  build-system = with python3Packages; [
    setuptools
    shtab # for shell completions
  ];

  dependencies = with python3Packages; [
    psutil
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "trashcli" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line interface to the freedesktop.org trashcan";
    homepage = "https://github.com/andreafrancia/trash-cli";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.unix;
    mainProgram = "trash";
  };
})
