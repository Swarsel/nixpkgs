{
  lib,
  stdenv,
  makeWrapper,
  pip,
  pipInstallHook,
  python,
  setuptools,
  setuptoolsBuildHook,
  unzip,
  wheel,
}:

stdenv.mkDerivation rec {
  inherit (pip) version;
  pname = "pip";

  postPatch = ''
    mkdir -p $out/bin
  '';

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildInputs = [ python ];

  # Should be propagatedNativeBuildInputs
  propagatedBuildInputs = [
    # Override to remove dependencies to prevent infinite recursion.
    (pipInstallHook.override { pip = null; })
    (setuptoolsBuildHook.override {
      setuptools = null;
      wheel = null;
    })
  ];

  installPhase =
    lib.optionalString (!stdenv.hostPlatform.isWindows) ''
      export SETUPTOOLS_INSTALL_WINDOWS_SPECIFIC_FILES=0
    ''
    + ''
      # Give folders a known name
      mv pip* pip
      mv setuptools* setuptools
      mv wheel* wheel
      # Set up PYTHONPATH:
      # - pip and setuptools need to be in PYTHONPATH to install setuptools, wheel, and pip.
      # - $out is where we are installing to and takes precedence, and is where wheel will end so we can install pip.
      export PYTHONPATH="$out/${python.sitePackages}:$(pwd)/pip/src:$(pwd)/setuptools:$(pwd)/setuptools/pkg_resources:$PYTHONPATH"

      echo "Building setuptools wheel..."
      pushd setuptools
      ${python.pythonOnBuildForHost.interpreter} -m pip install --no-build-isolation --no-index --prefix=$out  --ignore-installed --no-dependencies --no-cache .
      popd

      echo "Building wheel wheel..."
      pushd wheel
      ${python.pythonOnBuildForHost.interpreter} -m pip install --no-build-isolation --no-index --prefix=$out  --ignore-installed --no-dependencies --no-cache .
      popd

      echo "Building pip wheel..."
      pushd pip
      ${python.pythonOnBuildForHost.interpreter} -m pip install --no-build-isolation --no-index --prefix=$out  --ignore-installed --no-dependencies --no-cache .
      popd
    '';

  dontBuild = true;
  dontUsePipInstall = true;
  dontUseSetuptoolsBuild = true;
  name = "${python.libPrefix}-bootstrapped-${pname}-${version}";
  sourceRoot = ".";

  srcs = [
    wheel.src
    pip.src
    setuptools.src
  ];

  meta = {
    description = "Version of pip used for bootstrapping";
    homepage = pip.meta.homepage;
    license = lib.unique (pip.meta.license ++ setuptools.meta.license ++ wheel.meta.license);
  };
}
