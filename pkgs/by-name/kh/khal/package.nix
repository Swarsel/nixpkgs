{
  lib,
  stdenv,
  fetchFromGitHub,
  glibcLocales,
  installShellFiles,
  python3Packages,
  sphinxHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "khal";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "pimutils";
    repo = "khal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ltb2c9p/kD0PtYnLxRIm/SNlg+W+Vca6JSA7BahZ9uQ=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    glibcLocales
    installShellFiles
    sphinxHook
    python3Packages.sphinx-rtd-theme
    python3Packages.sphinxfeed-lsaffre
  ];

  env.LC_ALL = "en_US.UTF-8";
  doCheck = !stdenv.hostPlatform.isAarch64;

  nativeCheckInputs = with python3Packages; [
    freezegun
    hypothesis
    packaging
    pytestCheckHook
    vdirsyncer
  ];

  postInstall = ''
    # shell completions
    installShellCompletion --cmd khal \
      --bash <(_KHAL_COMPLETE=bash_source $out/bin/khal) \
      --zsh <(_KHAL_COMPLETE=zsh_source $out/bin/khal) \
      --fish <(_KHAL_COMPLETE=fish_source $out/bin/khal)

    # .desktop file
    install -Dm755 misc/khal.desktop -t $out/share/applications
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    click
    click-log
    configobj
    freezegun
    icalendar
    lxml
    pkginfo
    vdirsyncer
    python-dateutil
    pytz
    pyxdg
    requests-toolbelt
    tzlocal
    urwid
  ];

  disabledTests = [
    # timing based
    "test_etag"
    "test_bogota"
    "test_event_no_dst"
  ];

  pyproject = true;

  sphinxBuilders = [
    "html"
    "man"
  ];

  meta = {
    description = "CLI calendar application";
    homepage = "https://lostpackets.de/khal/";
    changelog = "https://github.com/pimutils/khal/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ antonmosich ];
  };
})
