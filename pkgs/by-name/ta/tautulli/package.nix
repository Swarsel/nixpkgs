{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tautulli";
  version = "2.17.2";

  src = fetchFromGitHub {
    owner = "Tautulli";
    repo = "Tautulli";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-BtKVGXJijxGK3CH0J49WKxBFG0pAp+zAw7YIJ4w5PCk=";
  };

  postPatch = ''
    substituteInPlace plexpy/config.py \
      --replace-fail "'CHECK_GITHUB': (int, 'General', 1)" "'CHECK_GITHUB': (int, 'General', 0)"
  '';

  nativeBuildInputs = [
    python3Packages.wrapPython
    makeWrapper
  ];

  checkPhase = ''
    runHook preCheck

    $out/bin/tautulli --help

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/tautulli
    cp -R contrib data lib plexpy Tautulli.py CHANGELOG.md $out/libexec/tautulli

    echo "master" > $out/libexec/tautulli/branch.txt
    echo "v${finalAttrs.version}" > $out/libexec/tautulli/version.txt

    # Can't just symlink to the main script, since it uses __file__ to
    # import bundled packages and manage the service
    makeWrapper $out/libexec/tautulli/Tautulli.py $out/bin/tautulli
    wrapPythonProgramsIn "$out/libexec/tautulli" "''${pythonPath[*]}"

    # Creat backwards compatibility symlink to bin/plexpy
    ln -s $out/bin/tautulli $out/bin/plexpy

    runHook postInstall
  '';

  pyproject = false;
  pythonPath = [ python3Packages.setuptools ];

  meta = {
    description = "Python based monitoring and tracking tool for Plex Media Server";
    homepage = "https://tautulli.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rhoriguchi ];
    platforms = lib.platforms.linux;
  };
})
