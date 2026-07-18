{
  lib,
  fetchFromGitHub,
  libarchive,
  makeWrapper,
  maven,
  openjdk25,
  replaceVars,
  stdenvNoCC,
}:
let
  # Wants at least Java 22
  jdk = openjdk25;
  version = "5.9.6";
in
maven.buildMavenPackage {
  inherit version;
  pname = "cratedb";

  src = fetchFromGitHub {
    owner = "crate";
    repo = "crate";
    tag = version;
    hash = "sha256-IBIOxcpd1MXMz+Z2utnjZfN74qX/ZrKVNrIjFaLKBEA=";
  };

  patches = [
    (replaceVars ./fix-poms.patch { inherit jdk; })
  ];

  nativeBuildInputs = [
    libarchive
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    # Don't install the bundled JDK; symlink instead.
    # Fixing all the paths in the script is frankly way too much work.
    bsdtar -xf app/target/crate-${version}.tar.gz -C $out --exclude="*/jdk/*" --strip-components=1
    ln -s ${jdk} $out/jdk

    runHook postInstall
  '';

  postFixup = ''
    # By default it wants to write to $out/data and $out/logs. Bad program.
    wrapProgram $out/bin/crate \
      --set CRATE_DISABLE_GC_LOGGING 1 \
      --add-flags '-Cpath.data="''${XDG_DATA_HOME:-$HOME/.local/share}/crate"' \
      --add-flags '-Cpath.logs="''${XDG_STATE_HOME:-$HOME/.local/state}/crate"'
  '';

  mvnHash = "sha256-p0LSR6I876/JNfrLp19PnLAx00gL4E2mZK+CO8X2IzU=";
  mvnJdk = jdk;
  mvnParameters = "-DskipTests";

  meta = {
    description = "Distributed and scalable SQL database";

    longDescription = ''
      CrateDB is a distributed SQL database that makes it simple to store and analyze massive
      amounts of data in real-time.

      CrateDB offers the benefits of an SQL database and the scalability and flexibility typically
      associated with NoSQL databases. Modest CrateDB clusters can ingest tens of thousands of records
      per second without breaking a sweat. You can run ad-hoc queries using standard SQL.
      CrateDB's blazing-fast distributed query execution engine parallelizes query workloads across
      the whole cluster.
    '';

    homepage = "https://cratedb.com/database";
    changelog = "https://cratedb.com/docs/crate/reference/en/latest/appendices/release-notes/${version}.html";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "crate";
    # FIXME: Somehow dependencies are platform-dependent. Somehow.
    broken = stdenvNoCC.hostPlatform.system != "x86_64-linux";
  };
}
