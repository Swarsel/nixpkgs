{
  lib,
  fetchurl,
  buildPythonPackage,
  casaconfig,
  casatools,
  certifi,
  common-updater-scripts,
  curl,
  fetchgit,
  gnugrep,
  gnused,
  jdk,
  matplotlib,
  pipInstallHook,
  pyerfa,
  scipy,
  setuptools,
  wheel,
  writeShellScript,
}:
buildPythonPackage (finalAttrs: {
  pname = "casatasks";
  version = "6.7.5.18";

  src = fetchgit {
    url = "https://open-bitbucket.nrao.edu/scm/casa/casa6.git";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-75oIlaNAyu70KWSjz38LoYAvV7RJgzH/X9uBnGpriF4=";
    fetchSubmodules = false;
  };

  postPatch = ''
    mkdir -p java
    cp ${finalAttrs.xml_jar} java/${finalAttrs.jarName}
  '';

  nativeBuildInputs = [
    jdk
    wheel
    setuptools
    pipInstallHook
  ];

  propagatedBuildInputs = [
    casatools
    casaconfig
    matplotlib
    scipy
    certifi
    pyerfa
  ];

  buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)
      mkdir -p $HOME/.casa/data
      cat > $HOME/.casa/config.py <<EOF
    measures_auto_update=False
    data_auto_update=False
    EOF
      python setup.py bdist_wheel --version ${finalAttrs.version}
      runHook postBuild
  '';

  # Tests require a full CASA data directory and network access
  doCheck = false;
  format = "other";
  jarName = "xml-casa-assembly-1.88.jar";
  sourceRoot = "${finalAttrs.src.name}/casatasks";

  xml_jar = fetchurl {
    hash = "sha256-UJCiXLXAe7Prm1qGXJ9jbuZcgKhPTSrU8qnf4C5Goxs="; # xml-jar
    url = "http://casa.nrao.edu/download/devel/xml-casa/java/${finalAttrs.jarName}";
  };

  passthru.updateScript = writeShellScript "update-casatasks" ''
    set -euo pipefail
    version=$(${lib.getExe curl} -s https://pypi.org/pypi/casatasks/json | ${lib.getExe gnugrep} -oP '"version"\s*:\s*"\K[^"]+' | head -1)
    ${lib.getExe' common-updater-scripts "update-source-version"} python3Packages.casatasks "$version"

    # Extract the jar filename from the xml-casa script at the new tag
    jar_name=$(${lib.getExe curl} -s \
      "https://open-bitbucket.nrao.edu/rest/api/1.0/projects/CASA/repos/casa6/raw/casatools/scripts/xml-casa?at=refs/tags/$version" | \
      ${lib.getExe gnugrep} -oP '(?<=jarfile_name = ").*(?=")')
    jar_url="http://casa.nrao.edu/download/devel/xml-casa/java/$jar_name"
    jar_sri=$(nix-prefetch-url --type sha256 "$jar_url" | xargs nix hash convert --hash-algo sha256 --to sri)

    nix_file=pkgs/development/python-modules/casatasks/default.nix
    ${lib.getExe gnused} -i \
      -e "s|xml-casa-assembly-[^ \"]*\.jar|$jar_name|" \
      -e "s|hash = \"sha256-.*\"; # xml-jar|hash = \"$jar_sri\"; # xml-jar|" \
      "$nix_file"
  '';

  meta = {
    description = "High-level Python tasks for radio astronomy data reduction";
    homepage = "https://casa.nrao.edu/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ kiranshila ];
    platforms = lib.platforms.unix;
  };
})
