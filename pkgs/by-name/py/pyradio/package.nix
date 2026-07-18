{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pyradio";
  version = "0.9.3.11.31";

  src = fetchFromGitHub {
    owner = "coderholic";
    repo = "pyradio";
    tag = finalAttrs.version;
    hash = "sha256-DZ/HffM53uBYpucIq9UEIIzkIeF/WxXCnC1tB++LD9c=";
  };

  postPatch = ''
    # Disable update check
    substituteInPlace pyradio/config \
      --replace-fail "distro = None" "distro = NixOS"
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  checkPhase = ''
    $out/bin/pyradio --help
  '';

  postInstall = ''
    installManPage *.1

    install -Dm644 $src/devel/pyradio.desktop \
      "$out/share/applications/pyradio.desktop"

    install -Dm644 "$src/pyradio/icons/pyradio.png" \
      "$out/share/icons/hicolor/512x512/apps/pyradio.png"
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    dnspython
    netifaces
    psutil
    python-dateutil
    rapidfuzz
    requests
    rich
  ];

  pyproject = true;

  meta = {
    description = "Curses based internet radio player";
    homepage = "https://github.com/coderholic/pyradio";
    changelog = "https://github.com/coderholic/pyradio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      contrun
      magicquark
      yayayayaka
    ];

    mainProgram = "pyradio";
  };
})
