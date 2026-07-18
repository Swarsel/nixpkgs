{
  lib,
  fetchurl,
  mercurial,
  python3Packages,
  qt5,
}:

let
  version = "7.0.1";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "tortoisehg";

  src = fetchurl {
    url = "https://www.mercurial-scm.org/release/tortoisehg/targz/tortoisehg-${version}.tar.gz";
    hash = "sha256-rCDLZ2ppD3Y71c31UNir/1pW1QBJViMP9JdoJiWf0nk=";
  };

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    # Makes wrapQtAppsHook add these qt libraries to the wrapper search paths
    qt5.qtwayland
  ];

  # In python3Packages.buildPythonApplication doCheck is always true, and we
  # override it to not run the default unittests
  checkPhase = ''
    runHook preCheck

    $out/bin/thg version | grep -q "${version}"
    # Detect breakage of thg in case of out-of-sync mercurial update. In that
    # case any thg subcommand just opens up an gui dialog with a description of
    # version mismatch.
    echo "thg smoke test"
    $out/bin/thg -h > help.txt &
    sleep 1s
    grep -q "list of commands" help.txt

    runHook postCheck
  '';

  # Convenient alias
  postInstall = ''
    ln -s $out/bin/thg $out/bin/tortoisehg
    install -D --mode=0644 contrib/thg.desktop --target-directory $out/share/applications/
  '';

  # In order to spare double wrapping, we use:
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    mercurial
    # The one from python3Packages
    qscintilla-qt5
    iniparse
  ];

  pyproject = true;

  passthru = {
    # If at some point we'll override this argument, it might be useful to have
    # access to it here.
    inherit mercurial;
  };

  meta = {
    description = "Qt based graphical tool for working with Mercurial";
    homepage = "https://tortoisehg.bitbucket.io/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      gbtb
    ];

    platforms = lib.platforms.linux;
  };
}
