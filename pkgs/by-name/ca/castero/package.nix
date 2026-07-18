{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "castero";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "xgi";
    repo = "castero";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6/7oCKBMEcQeJ8PaFP15Xef9sQRYCpigtzINv2M6GUY=";
  };

  # Satisfy the python-mpv dependency, which is mpv within NixOS
  postPatch = ''
    substituteInPlace setup.py --replace-fail "python-mpv" "mpv"
  '';

  propagatedBuildInputs =
    with python3.pkgs;
    [
      requests
      grequests
      cjkwrap
      pytz
      beautifulsoup4
      lxml
      mpv
      python-vlc
    ]
    ++ requests.optional-dependencies.socks;

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  # Resolve configuration tests, which access $HOME
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  # Disable tests that are problematic with pytest
  # Check NixOS/nixpkgs#333019 for more info about these
  disabledTests = [
    "test_datafile_download"
    "test_display_get_input_str"
    "test_display_get_y_n"
    # > assert mymenu.metadata == episode1.metadata
    # E AssertionError: assert '' == <MagicMock name='mock.metadata' id='140737279137104'>
    # E  +  where '' = <castero.menus.episodemenu.EpisodeMenu object at 0x7ffff3acd0d0>.metadata
    # E  +  and   <MagicMock name='mock.metadata' id='140737279137104'> = episode1.metadata
    "test_menu_episode_metadata"
    # flaky: segfaults on Hydra when a background DB reload thread races the test
    "test_perspective_downloaded_draw_metadata"
  ];

  enabledTestPaths = [
    "tests"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "castero"
  ];

  # VLC currently doesn't support Darwin on NixOS
  meta = {
    description = "TUI podcast client for the terminal";
    homepage = "https://github.com/xgi/castero";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ keto ];
    platforms = lib.platforms.linux;
    mainProgram = "castero";
  };
})
