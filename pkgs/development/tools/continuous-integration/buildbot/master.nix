{
  lib,
  stdenv,
  fetchFromGitHub,
  alembic,
  autobahn,
  boto3,
  brotli,
  buildPythonApplication,
  # Tie withPlugins through the fixed point here, so it will receive an
  # overridden version properly
  buildbot,
  buildbot-pkg,
  buildbot-plugins,
  buildbot-worker,
  croniter,
  git,
  importlib-resources,
  jinja2,
  lz4,
  makeWrapper,
  markdown,
  moto,
  msgpack,
  nixosTests,
  openssh,
  packaging,
  parameterized,
  pyjwt,
  pypugjs,
  python,
  python-dateutil,
  pyyaml,
  setuptools,
  setuptools-trial,
  sqlalchemy,
  treq,
  twisted,
  txaio,
  txrequests,
  unidiff,
  zope-interface,
  zstandard,
}:

let
  withPlugins =
    plugins:
    buildPythonApplication rec {
      inherit (buildbot) version;
      pname = "${buildbot.pname}-with-plugins";

      nativeBuildInputs = [
        makeWrapper
      ];

      propagatedBuildInputs = plugins ++ buildbot.propagatedBuildInputs;
      doCheck = false;

      installPhase = ''
        makeWrapper ${buildbot}/bin/buildbot $out/bin/buildbot \
          --prefix PYTHONPATH : "${buildbot}/${python.sitePackages}:$PYTHONPATH"
        ln -sfv ${buildbot}/lib $out/lib
      '';

      dontBuild = true;
      dontUnpack = true;
      pyproject = false;

      passthru = buildbot.passthru // {
        inherit pyproject;
        withPlugins = morePlugins: withPlugins (morePlugins ++ plugins);
      };
    };
in
buildPythonApplication rec {
  pname = "buildbot";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "buildbot";
    repo = "buildbot";
    rev = "v${version}";
    hash = "sha256-yUtOJRI04/clCMImh5sokpj6MeBIXjEAdf9xnToqJZs=";
  };

  patches = [
    # This patch disables the test that tries to read /etc/os-release which
    # is not accessible in sandboxed builds.
    ./skip_test_linux_distro.patch
  ];

  postPatch = ''
    cd master
    touch buildbot/py.typed
    substituteInPlace buildbot/scripts/logwatcher.py --replace '/usr/bin/tail' "$(type -P tail)"
  '';

  # TimeoutErrors on slow machines -> aarch64
  doCheck = !stdenv.hostPlatform.isAarch64;

  nativeCheckInputs = [
    treq
    txrequests
    pypugjs
    boto3
    moto
    markdown
    lz4
    setuptools-trial
    buildbot-worker
    buildbot-pkg
    buildbot-plugins.www
    parameterized
    git
    openssh
  ];

  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  build-system = [ setuptools ];

  dependencies = [
    # core
    twisted
    jinja2
    msgpack
    zope-interface
    sqlalchemy
    alembic
    python-dateutil
    txaio
    autobahn
    pyjwt
    pyyaml
    croniter
    importlib-resources
    packaging
    unidiff
    treq
    brotli
    zstandard
  ]
  # tls
  ++ twisted.optional-dependencies.tls;

  pyproject = true;

  pythonRelaxDeps = [
    "twisted"
  ];

  passthru = {
    inherit withPlugins python;
    updateScript = ./update.sh;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isLinux {
    tests = {
      inherit (nixosTests) buildbot;
    };
  };

  meta = {
    description = "Open-source continuous integration framework for automating software build, test, and release processes";
    homepage = "https://buildbot.net/";
    changelog = "https://github.com/buildbot/buildbot/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.buildbot ];
  };
}
