{
  lib,
  fetchFromGitHub,
  glib,
  gsettings-desktop-schemas,
  python3Packages,
  unstableGitUpdater,
  wrapGAppsHook3,
  writeShellScript,
}:

python3Packages.buildPythonApplication {
  pname = "chirp";
  version = "0.4.0-unstable-2026-05-07";

  src = fetchFromGitHub {
    owner = "kk7ds";
    repo = "chirp";
    rev = "a89815c5c1575d7ab2c4bfae2ce153611f64e804";
    hash = "sha256-nreWF3eyFuokRWm2SyOsf1tq7J1q2ox1vKqsjJSiUlQ=";
  };

  postPatch = ''
    substituteInPlace chirp/locale/Makefile \
      --replace-fail /usr/bin/find find
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
  ];

  preBuild = ''
    make -C chirp/locale
  '';

  # many upstream test failures
  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-xdist
    ddt
    pyyaml
  ];

  preCheck = ''
    export HOME="$TMPDIR"
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pyserial
    requests
    yattag
    suds
    lark
    wxpython
  ];

  pyproject = true;

  passthru.updateScript = unstableGitUpdater {
    tagConverter = writeShellScript "chirp-tag-converter.sh" ''
      sed -e 's/^release_//g' -e 's/_/./g'
    '';
  };

  meta = {
    description = "Free, open-source tool for programming your amateur radio";
    homepage = "https://chirp.danplanet.com/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      emantor
      wrmilling
      nickcao
      ethancedwards8
    ];

    platforms = lib.platforms.unix;
  };
}
