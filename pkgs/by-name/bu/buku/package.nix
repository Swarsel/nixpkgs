{
  lib,
  fetchFromGitHub,
  python3,
  withServer ? false,
}:

let
  serverRequire = with python3.pkgs; [
    requests
    flasgger
    flask
    flask-admin
    flask-api
    flask-babel
    flask-bootstrap
    flask-paginate
    flask-wtf
    arrow
    werkzeug
    click
    vcrpy
    toml
  ];
in
with python3.pkgs;
buildPythonApplication (finalAttrs: {
  pname = "buku";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "buku";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-7dxe1GUdBDP/mNfYKkJzKNTgzXLfVQxp4REEkFIh4Bs=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    cryptography
    beautifulsoup4
    certifi
    urllib3
    html5lib
  ]
  ++ lib.optionals withServer serverRequire;

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-recording
    pyyaml
    mypy-extensions
    click
    pylint
    flake8
    pytest-cov-stub
    pyyaml
  ]
  ++ lib.optionals withServer [
    lxml
    pytest-timeout
  ];

  preCheck = lib.optionalString (!withServer) ''
    rm tests/test_{server,views}.py
  '';

  postInstall = ''
    make install PREFIX=$out

    mkdir -p $out/share/zsh/site-functions $out/share/bash-completion/completions $out/share/fish/vendor_completions.d
    cp auto-completion/zsh/* $out/share/zsh/site-functions
    cp auto-completion/bash/* $out/share/bash-completion/completions
    cp auto-completion/fish/* $out/share/fish/vendor_completions.d
  ''
  + lib.optionalString (!withServer) ''
    rm $out/bin/bukuserver
  '';

  pyproject = true;

  meta = {
    description = "Private cmdline bookmark manager";
    homepage = "https://github.com/jarun/Buku";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "buku";
  };
})
