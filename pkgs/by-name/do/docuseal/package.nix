{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  fetchYarnDeps,
  makeWrapper,
  nixosTests,
  nodejs,
  pdfium-binaries,
  ruby_4_0,
  yarn,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "docuseal";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "docusealco";
    repo = "docuseal";
    tag = finalAttrs.version;
    hash = "sha256-9fDEj9gOBZrn4dNWf+QRCZs3gUv3Mx/YZLRx55ShS7E=";
    # https://github.com/docusealco/docuseal/issues/505#issuecomment-3153802333
    postFetch = "rm $out/db/schema.rb";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [ finalAttrs.rubyEnv ];
  propagatedBuildInputs = [ finalAttrs.rubyEnv.wrappedRuby ];

  env = {
    BUNDLE_WITHOUT = "development:test";
    RAILS_ENV = "production";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/public/packs
    cp -r ./* $out
    cp -r ${finalAttrs.docusealWeb}/* $out/public/packs

    bundle exec bootsnap precompile --gemfile app/ lib/

    runHook postInstall
  '';

  # create empty folder which are needed, but never used
  postInstall = ''
    chmod +w $out/tmp/
    mkdir -p $out/tmp/{cache,sockets}
  '';

  postFixup = ''
    wrapProgram $out/bin/rails \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pdfium-binaries ]}"
  '';

  docusealWeb = stdenv.mkDerivation {
    inherit (finalAttrs)
      version
      src
      meta
      ;

    pname = "docuseal-web";

    nativeBuildInputs = [
      yarn
      yarnConfigHook
      nodejs
      finalAttrs.rubyEnv
    ];

    # no idea how to patch ./bin/shakapacker. instead we execute the two bundle exec commands manually
    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)

      bundle exec rails assets:precompile
      bundle exec rails shakapacker:compile

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r public/packs $out

      runHook postInstall
    '';

    NODE_ENV = "production";
    RAILS_ENV = "production";

    offlineCache = fetchYarnDeps {
      inherit (finalAttrs) src;
      hash = "sha256-62nI/QUzlpI1VyZ6PWPz2kSp4S2GUIQDaf4jUwzyj24=";
    };
  };

  rubyEnv = bundlerEnv {
    gemdir = ./.;
    name = "docuseal-gems";
    ruby = ruby_4_0;
  };

  passthru = {
    tests = {
      inherit (nixosTests) docuseal-psql docuseal-sqlite;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Open source tool for creating, filling and signing digital documents";
    homepage = "https://www.docuseal.co/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
