{
  lib,
  stdenv,
  fetchFromGitHub,
  biome,
  buildNpmPackage,
  jdk25,
  makeWrapper,
  maven,
  nixosTests,
  unzip,
  writeText,
}:
let
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "Athou";
    repo = "commafeed";
    tag = version;
    hash = "sha256-n68REVBLThChiCq+Rx4Cy3KS/GlgOr5DBn2wzLWX6TY=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "commafeed-frontend";
    nativeBuildInputs = [ biome ];
    npmDepsHash = "sha256-bP0f2+n01YdZf/NCAWE41x/dezpHzYy4qvAscs/b+Lc=";

    installPhase = ''
      runHook preInstall

      cp -r dist/ $out

      runHook postInstall
    '';

    sourceRoot = "${src.name}/commafeed-client";
  };

  gitProperties = writeText "git.properties" ''
    git.branch = none
    git.build.time = 1970-01-01T00:00:00+0000
    git.build.version = ${version}
    git.commit.id = none
    git.commit.id.abbrev = none
  '';
in
maven.buildMavenPackage {
  inherit version src;
  pname = "commafeed";

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    unzip -d $out/share/ commafeed-server/target/commafeed-$version-h2-jvm.zip

    makeWrapper ${jdk25}/bin/java $out/bin/commafeed \
      --add-flags "-jar $out/share/commafeed-$version-h2/quarkus-run.jar"

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    ln -sf "${frontend}" commafeed-client/dist

    cp ${gitProperties} commafeed-server/src/main/resources/git.properties

    runHook postConfigure
  '';

  mvnHash = "sha256-P3pmU/ou/gErk91ANjD4QuBTldBPKHYtGJREJQVgde8=";
  mvnJdk = jdk25;

  mvnParameters = lib.escapeShellArgs [
    "-Dskip.installnodenpm"
    "-Dskip.npm"
    "-Dspotless.check.skip"
    "-Dmaven.gitcommitid.skip"
  ];

  passthru.tests = nixosTests.commafeed;

  meta = {
    description = "Google Reader inspired self-hosted RSS reader";
    homepage = "https://github.com/Athou/commafeed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ svrana ];
    mainProgram = "commafeed";
    broken = stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isAarch64;
  };
}
