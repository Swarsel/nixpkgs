{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
  testers,
  ...
}:
let
  version = fromTOML (builtins.readFile ./version.toml);

  src = fetchFromGitHub {
    owner = "graphhopper";
    repo = "graphhopper";
    tag = version.patch;
    hash = version.hash.src;
  };

  # Patch graphhopper to remove the npm download
  patches = [ ./remove-npm-dependency.patch ];

  # Graphhopper also relies on a maps bundle downloaded from npm
  # By default it installs nodejs and npm during the build,
  # But we patch that out so we much fetch it ourselves
  mapsBundle = fetchurl {
    hash = version.hash.mapsBundle;
    name = "@graphhopper/graphhopper-maps-bundle-${version.mapsBundle}";
    url = "https://registry.npmjs.org/@graphhopper/graphhopper-maps-bundle/-/graphhopper-maps-bundle-${version.mapsBundle}.tgz";
  };

  # We cannot use `buildMavenPackage` as we need to load in the
  # mapsBundle before doing anything
  mvnDeps = stdenv.mkDerivation {
    inherit src patches;
    buildInputs = [ maven ];

    buildPhase = ''
      # Fetching deps with mvn dependency:go-offline does not quite catch everything, so we use this plugin instead
      mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies \
        -Dmaven.repo.local=$out/.m2 \
        -Dmaven.wagon.rto=5000
    '';

    installPhase = ''
      # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
      find $out -type f \( \
        -name \*.lastUpdated \
        -o -name resolver-status.properties \
        -o -name _remote.repositories \) \
        -delete
    '';

    name = "graphhopper-dependencies";
    outputHash = version.hash.mvnDeps;
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit src patches;
  pname = "graphhopper";
  version = version.patch;
  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    maven
  ];

  # Build and skip tests because downloading of
  # test deps seems to not work with the go-offline plugin
  buildPhase = ''
    runHook preBuild

    mvn package --offline \
      -Dmaven.repo.local=${mvnDeps}/.m2 \
      -DskipTests

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    ln -s ${mvnDeps}/.m2 $out/lib

    # Grapphopper versions are seemingly compiled under the major release name,
    # not the patch name, which is the version we want for our package
    cp ./web/target/graphhopper-web-${version.major}-SNAPSHOT.jar $out/bin/graphhopper-web-${version.major}-SNAPSHOT.jar

    makeWrapper ${jre}/bin/java $out/bin/graphhopper \
      --add-flags "-jar $out/bin/graphhopper-web-${version.major}-SNAPSHOT.jar" \
      --chdir $out

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    mkdir -p ./web-bundle/target/
    ln -s ${mapsBundle} ./web-bundle/target/graphhopper-graphhopper-maps-bundle-${version.mapsBundle}.tgz

    runHook postConfigure
  '';

  fixupPhase = ''
    runHook preFixup

    # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
    find $out -type f \( \
      -name \*.lastUpdated \
      -o -name resolver-status.properties \
      -o -name _remote.repositories \) \
      -delete

    runHook postFixup
  '';

  passthru = {
    tests.version = testers.testVersion {
      version = "graphhopper-web-${version.major}-SNAPSHOT.jar";
      # `graphhopper --version` does not work as the source does not specify `Implementation-Version`
      command = "graphhopper --help";
      package = finalAttrs.finalPackage;
    };

    updateScript = ./update.nu;
  };

  meta = {
    description = "Fast and memory-efficient routing engine for OpenStreetMap";
    homepage = "https://www.graphhopper.com/";
    changelog = "https://github.com/graphhopper/graphhopper/releases/tag/${version.patch}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ baileylu ];
    platforms = lib.platforms.all;
    mainProgram = "graphhopper";
    teams = [ lib.teams.geospatial ];
  };
})
