{
  lib,
  fetchFromGitLab,
  dpkg,
  fakeroot,
  gitMinimal,
  python3Packages,
  rpm,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "apkg";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "packaging";
    repo = "apkg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UQHiG6clAt+pmc0MTCkO4NIzr8TZmJ6Yd/T0YTkBxv0=";
    domain = "gitlab.nic.cz";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools # required for build
  ];

  propagatedBuildInputs = with python3Packages; [
    # copy&pasted requirements.txt (almost exactly)
    beautifulsoup4 # upstream version detection
    blessed # terminal colors
    build # apkg distribution
    cached-property # for python <= 3.7; but pip complains even with 3.8
    click # nice CLI framework
    distro # current distro detection
    jinja2 # templating
    packaging # version parsing
    pyyaml # YAML for serialization
    requests # HTTP for humans™
    toml # TOML for config files
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
  ];

  checkPhase = ''
    runHook preCheck
    py.test # inspiration: .gitlab-ci.yml
    runHook postCheck
  '';

  makeWrapperArgs = [
    # deps for `srcpkg` operation for other distros; could be optional
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      gitMinimal
      rpm
      dpkg
      fakeroot
    ])
  ];

  pyproject = true;

  meta = {
    description = "Upstream packaging automation tool";
    homepage = "https://pkg.labs.nic.cz/pages/apkg";
    license = lib.licenses.gpl3Plus;

    maintainers = [
      lib.maintainers.vcunat # close to upstream
    ];

    mainProgram = "apkg";
  };
})
