{
  lib,
  fetchFromGitHub,
  cdrdao,
  fetchpatch,
  flac,
  glib,
  gobject-introspection,
  installShellFiles,
  libcdio-paranoia,
  libsndfile,
  python3,
  sox,
  testers,
  util-linux,
  whipper,
  wrapGAppsNoGuiHook,
}:

let
  bins = [
    libcdio-paranoia
    cdrdao
    flac
    sox
    util-linux
  ];
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "whipper";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "whipper-team";
    repo = "whipper";
    rev = "v${finalAttrs.version}";
    sha256 = "00cq03cy5dyghmibsdsq5sdqv3bzkzhshsng74bpnb5lasxp3ia5";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (fetchpatch {
      sha256 = "0n9dmib884y8syvypsg88j0h71iy42n1qsrh0am8pwna63sl15ah";
      # Use custom YAML subclass to be compatible with ruamel_yaml>=0.17
      # https://github.com/whipper-team/whipper/pull/543
      url = "https://github.com/whipper-team/whipper/commit/3ce5964dfe8be1e625c3e3b091360dd0bc34a384.patch";
    })
  ];

  nativeBuildInputs = [
    installShellFiles
    wrapGAppsNoGuiHook
    gobject-introspection
  ];

  buildInputs = [
    libsndfile
    glib
  ];

  propagatedBuildInputs = with python3.pkgs; [
    musicbrainzngs
    mutagen
    pycdio
    pygobject3
    ruamel-yaml
    discid
    pillow
    setuptools_80
  ];

  postBuild = ''
    make -C man
  '';

  nativeCheckInputs =
    with python3.pkgs;
    [
      twisted
      pytestCheckHook
    ]
    ++ bins;

  preCheck = ''
    # disable tests that require internet access
    # https://github.com/JoeLametta/whipper/issues/291
    substituteInPlace whipper/test/test_common_accurip.py \
      --replace "test_AccurateRipResponse" "dont_test_AccurateRipResponse"
    export HOME=$TMPDIR
  '';

  postInstall = ''
    installManPage man/*.1
  '';

  build-system = with python3.pkgs; [
    docutils
    setuptools-scm
  ];

  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath bins)
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = true;

  passthru.tests.version = testers.testVersion {
    command = "HOME=$TMPDIR whipper --version";
    package = whipper;
  };

  meta = {
    description = "CD ripper aiming for accuracy over speed";
    homepage = "https://github.com/whipper-team/whipper";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ emily ];
    platforms = lib.platforms.unix;
    mainProgram = "whipper";
  };
})
