{
  lib,
  stdenv,
  fetchFromGitHub,
  applyPatches,
  bundlerEnv,
  ruby_3_4,
  tailwindcss_4,
}:
let
  sources = lib.importJSON ./sources.json;
  inherit (sources) version;

  src = applyPatches {
    postPatch = ''
      cp -f ${./rubyEnv/Gemfile} ./Gemfile
      cp -f ${./rubyEnv/Gemfile.lock} ./Gemfile.lock
    '';

    src = fetchFromGitHub {
      inherit (sources)
        owner
        repo
        hash
        ;

      tag = sources.version;
    };
  };

  rubyEnv = bundlerEnv rec {
    inherit version;
    gemdir = src;
    gemset = ./rubyEnv/gemset.nix;
    name = "sure-ruby-env-${version}";
    ruby = ruby_3_4;
  };
in
stdenv.mkDerivation rec {
  inherit src version;
  pname = "sure";
  strictDeps = true;

  nativeBuildInputs = [
    rubyEnv
    rubyEnv.wrappedRuby
  ];

  buildInputs = [
    rubyEnv.wrappedRuby
  ];

  env = {
    RAILS_ENV = "production";
    TAILWINDCSS_INSTALL_DIR = "${tailwindcss_4}/bin";
  };

  buildPhase = ''
    runHook preBuild
    patchShebangs bin/

    bundle exec bootsnap precompile --gemfile -j 0
    bundle exec bootsnap precompile -j 0 app/ lib/

    SECRET_KEY_BASE_DUMMY=1 bundle exec rake assets:precompile

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r {public,bin,app,config,db,lib,vendor} $out/
    cp -r {Rakefile,config.ru} $out/

    ln -s /run/sure/tmp $out/tmp
    ln -s /run/sure/log $out/log
    ln -s /run/sure/storage $out/storage

    runHook postInstall
  '';

  __structuredAttrs = true;

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "Personal finance app for everyone";
    homepage = "https://sure.am/";
    changelog = "https://github.com/we-promise/sure/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      _74k1
      pjrm
    ];

    platforms = lib.platforms.linux;
  };
}
