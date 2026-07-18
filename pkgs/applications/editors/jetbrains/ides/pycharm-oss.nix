{
  lib,
  mkJetBrainsProduct,
  mkJetBrainsSource,
  pyCharmCommonOverrides,
}:
let
  src = mkJetBrainsSource {
    androidHash = "sha256-FA/6ry1M7+RISJL+2SR9QkDvAGJAkXhFMh9YoOEU5nk=";
    buildNumber = "253.31033.139";
    buildType = "pycharm";
    ideaHash = "sha256-GRlWzpHvgy7P+vw+UWApyPpLLzWiHmvsC8HLPUyrshQ=";
    jpsHash = "sha256-iHpt926BDLNUwHRXvkqVgwlWiLo1qSZEaGeJcS0Fjmk=";

    kotlin-jps-plugin = {
      version = "2.2.20";
      hash = "sha256-+jGghK2+yq+YFm5zT7ob+WTgTiJnHXAjDtlZjOzSISQ=";
    };

    mvnDeps = ../source/pycharm_maven_artefacts.json;

    repositories = [
      "repo1.maven.org/maven2"
      "packages.jetbrains.team/maven/p/ij/intellij-dependencies"
      "dl.google.com/dl/android/maven2"
      "download.jetbrains.com/teamcity-repository"
      "packages.jetbrains.team/maven/p/grazi/grazie-platform-public"
      "packages.jetbrains.team/maven/p/kpm/public"
      "packages.jetbrains.team/maven/p/ki/maven"
      "maven.pkg.jetbrains.space/public/p/compose/dev"
      "packages.jetbrains.team/maven/p/amper/amper"
      "packages.jetbrains.team/maven/p/kt/bootstrap"
    ];

    restarterHash = "sha256-acCmC58URd6p9uKZrm0qWgdZkqu9yqCs23v8qgxV2Ag=";
    # update-script-start: source-args
    version = "2025.3.3";
    # update-script-end: source-args
  };
in
(mkJetBrainsProduct {
  inherit src;

  inherit (src)
    version
    buildNumber
    libdbm
    fsnotifier
    ;

  pname = "pycharm-oss";
  product = "PyCharm Open Source";
  productShort = "PyCharm";
  wmClass = "jetbrains-pycharm-ce";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Free Python IDE from JetBrains (built from source)";

    longDescription = ''
      Python IDE with complete set of tools for productive development with Python programming language.
      In addition, the IDE provides high-class capabilities for professional Web development with Django framework and Google App Engine.
      It has powerful coding assistance, navigation, a lot of refactoring features, tight integration with various Version Control Systems, Unit testing and powerful Debugger.
    '';

    homepage = "https://www.jetbrains.com/pycharm/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];

    maintainers = with lib.maintainers; [
      tymscar
    ];
  };
}).overrideAttrs
  pyCharmCommonOverrides
