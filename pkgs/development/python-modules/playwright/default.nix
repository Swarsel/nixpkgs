{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  gitMinimal,
  # dependencies
  greenlet,
  nixosTests,
  nodejs,
  playwright-driver,
  pyee,
  python,
  # patches
  replaceVars,
  # build-system
  setuptools,
  setuptools-scm,
  writableTmpDirAsHomeHook,
}:

let
  driver = playwright-driver;
in
buildPythonPackage (finalAttrs: {
  pname = "playwright";
  # run ./pkgs/development/web/playwright/update.sh to update
  version = "1.61.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6FIUFDa23q0Ge0G1ZmaYDitVYzZzOHatQtLRvZ18W0Q=";
  };

  patches = [
    # This patches two things:
    # - The driver location, which is now a static package in the Nix store.
    # - The setup script, which would try to download the driver package from
    #   a CDN and patch wheels so that they include it. We don't want this
    #   we have our own driver build.
    (replaceVars ./driver-location.patch {
      driver = "${driver}/cli.js";
      nodejs = lib.getExe nodejs;
    })
  ];

  postPatch = ''
    # Use sed with a regex instead of substituteInPlace so we don't have to
    # bump pinned versions on every upstream release. grep -q precheck makes
    # the build fail loudly if upstream restructures the requires list.
    grep -q 'requires = \["setuptools==.*", "setuptools-scm==.*", "wheel==.*", "auditwheel==.*"\]' pyproject.toml
    sed -i -e 's/requires = \["setuptools==.*", "setuptools-scm==.*", "wheel==.*", "auditwheel==.*"\]/requires = ["setuptools", "setuptools-scm", "wheel"]/' pyproject.toml

    # setup.py downloads and extracts the driver.
    # This is done manually in postInstall instead.
    rm setup.py
  '';

  nativeBuildInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  # Skip tests because they require network access.
  doCheck = false;

  postInstall = ''
    ln -s ${driver} $out/${python.sitePackages}/playwright/driver
  '';

  build-system = [
    setuptools-scm
    setuptools
  ];

  dependencies = [
    greenlet
    pyee
  ];

  pyproject = true;
  pythonImportsCheck = [ "playwright" ];

  pythonRelaxDeps = [
    "greenlet"
    "pyee"
  ];

  passthru = {
    inherit driver;
    # Package and playwright driver versions are tightly coupled.
    # Use the update script to ensure synchronized updates.
    skipBulkUpdate = true;

    tests = {
      inherit driver;
      browsers = playwright-driver.browsers;
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      inherit (nixosTests) playwright-python;
    };
  };

  meta = {
    description = "Python version of the Playwright testing and automation library";
    homepage = "https://github.com/microsoft/playwright-python";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      techknowlogick
      yrd
      kalekseev
    ];

    mainProgram = "playwright";
  };
})
