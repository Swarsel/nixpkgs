{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  gsettings-desktop-schemas,
  jdk,
  makeWrapper,
}:
let
  # "Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0."
  gradle = gradle_8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mucommander";
  version = "1.5.2-1";

  src = fetchFromGitHub {
    owner = "mucommander";
    repo = "mucommander";
    rev = finalAttrs.version;
    sha256 = "sha256-J1paBXlAGe2eKMg4wvaXTzMIiSMFIJ1XIAaKrfOwQLc=";
  };

  postPatch = ''
    # there is no .git anyway
    substituteInPlace build.gradle \
      --replace "git = grgit.open(dir: project.rootDir)" "" \
      --replace "revision = git.head().id" "revision = '${finalAttrs.version}'"
  '';

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/share/mucommander
    tar xvf build/distributions/mucommander-*.tgz --directory=$out/share/mucommander

    makeWrapper $out/share/mucommander/mucommander.sh $out/bin/mucommander \
      --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name} \
      --set JAVA_HOME ${jdk}
  '';

  __darwinAllowLocalNetworking = true;
  gradleBuildTask = "tgz";

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  meta = {
    description = "Cross-platform file manager";
    homepage = "https://www.mucommander.com/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ jiegec ];
    platforms = lib.platforms.all;
    mainProgram = "mucommander";
  };
})
