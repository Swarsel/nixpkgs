{
  lib,
  fetchFromGitHub,
  ffmpeg,
  installShellFiles,
  nix-update-script,
  perl,
  python3Packages,
}:

let

  inherit (python3Packages)
    buildPythonApplication
    setuptools
    requests
    pysocks
    cryptography
    pyyaml
    pytestCheckHook
    mock
    requests-mock
    ;

  version = "4.191";

in

buildPythonApplication {
  inherit version;
  pname = "svtplay-dl";

  src = fetchFromGitHub {
    owner = "spaam";
    repo = "svtplay-dl";
    tag = version;
    hash = "sha256-BOgCJeEUUTt1BoyalBbzgmTS2EaAgFpzhKtWvjBC+VI=";
  };

  nativeBuildInputs = [
    # For `pod2man(1)`.
    perl
    installShellFiles
  ];

  postBuild = ''
    make svtplay-dl.1
  '';

  nativeCheckInputs = [
    pytestCheckHook
    mock
    requests-mock
  ];

  postInstall = ''
    installManPage svtplay-dl.1
    makeWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [ ffmpeg ]}")
  '';

  build-system = [ setuptools ];

  dependencies = [
    requests
    pysocks
    cryptography
    pyyaml
  ];

  enabledTestPaths = [
    "lib"
  ];

  postInstallCheck = ''
    $out/bin/svtplay-dl --help > /dev/null
  '';

  pyproject = true;

  pytestFlags = [
    "--doctest-modules"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool to download videos from svtplay.se and other sites";
    homepage = "https://github.com/spaam/svtplay-dl";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "svtplay-dl";
  };
}
