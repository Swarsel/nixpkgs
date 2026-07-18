{
  lib,
  fetchzip,
  makeWrapper,
  openjdk,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "android-studio-tools";
  version = "14742923";

  src = fetchzip {
    # The only difference between the Linux and Mac versions is a single comment at the top of all the scripts
    # Therefore, we will use the Linux version and just patch the comment
    url = "https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip";
    hash = "sha256-oimC4ToDFIa8Rlv+5RB+swl8M5PHdX4omlrMZMQEx8M=";
  };

  postPatch = ''
    find . -type f -not -path "./bin/*" -exec chmod -x {} \;
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    for f in cmdline-tools/bin/*; do
      sed -i 's|start up script for Linux|start up script for Mac|' $f
    done
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r . $out

    for f in $out/bin/*; do
      wrapProgram $f --set JAVA_HOME "${openjdk}"
    done

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Android Studio CLI Tools";
    homepage = "https://developer.android.com/studio";
    changelog = "https://developer.android.com/studio/releases";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource ]; # The 'binaries' are actually shell scripts
    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = lib.platforms.all;
    downloadPage = "https://developer.android.com/studio";
    teams = [ lib.teams.android ];
  };
}
