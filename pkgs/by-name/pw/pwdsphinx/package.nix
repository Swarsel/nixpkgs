{
  lib,
  fetchFromGitHub,
  installShellFiles,
  pandoc,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pwdsphinx";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "stef";
    repo = "pwdsphinx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wAvcXSAoaottnsnvlD2QnLP3QIithI6xplo5tN8yjVg=";
  };

  postPatch = ''
    substituteInPlace ./setup.py \
      --replace-fail 'zxcvbn-python' 'zxcvbn'
  '';

  # for man pages
  nativeBuildInputs = [
    installShellFiles
    pandoc
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    mkdir -p ~/.config/sphinx
    cp ${finalAttrs.src}/sphinx.cfg_sample ~/.config/sphinx/config
    substituteInPlace ~/.config/sphinx/config \
      --replace-fail 'pinentry=/usr/bin/pinentry' 'pinentry="/usr/bin/pinentry"' \
      --replace-fail 'log=' 'log=""'
    # command fails without key but the command generates the key, so always pass
    $out/bin/sphinx init || true
  '';

  postInstall = ''
    mkdir -p $out/share/doc/pwdsphinx/
    cp -r ./configs $out/share/doc/pwdsphinx/
    installManPage man/*.1
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    cbor2
    pyequihash
    pyoprf
    pysodium
    qrcodegen
    securestring
    zxcvbn
  ];

  pyproject = true;
  pythonImportsCheck = [ "pwdsphinx" ];

  meta = {
    description = "Native backend for web-extensions for Sphinx-based password storage";
    homepage = "https://www.ctrlc.hu/~stef/blog/posts/sphinx.html";
    changelog = "https://github.com/stef/pwdsphinx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sphinx";
    downloadPage = "https://github.com/stef/pwdsphinx";
    teams = [ lib.teams.ngi ];
  };
})
