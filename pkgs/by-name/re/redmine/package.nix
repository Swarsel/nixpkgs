{
  lib,
  fetchurl,
  buildRubyGem,
  bundlerEnv,
  cargo,
  defaultGemConfig,
  makeWrapper,
  nixosTests,
  openssl,
  ruby_4_0,
  rustPlatform,
  rustc,
  stdenvNoCC,
}:

let
  version = "7.0.0";
  rubyEnv = bundlerEnv {
    gemConfig = defaultGemConfig // {
      commonmarker = attrs: {
        nativeBuildInputs = [
          cargo
          rustc
          rustPlatform.cargoSetupHook
          rustPlatform.bindgenHook
        ];

        preInstall = ''
          export CARGO_HOME="$PWD/../.cargo/"
        '';

        postInstall = ''
          find $out -type f -name .rustc_info.json -delete
        '';

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit (buildRubyGem { inherit (attrs) gemName version source; })
            name
            src
            unpackPhase
            nativeBuildInputs
            ;

          hash = "sha256-Xw0VWl3qZLvNNmRFHuWkltC1XfoIaHJKWM8Po4FSmoQ=";
        };

        disallowedReferences = [
          rustc.unwrapped
        ];

        dontBuild = false;
      };

      trilogy = attrs: {
        buildInputs = [ openssl ];
      };
    };

    gemdir = ./.;

    groups = [
      "development"
      "ldap"
      "markdown"
      "common_mark"
      "minimagick"
      "test"
    ];

    name = "redmine-env-${version}";
    ruby = ruby_4_0;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "redmine";

  src = fetchurl {
    url = "https://www.redmine.org/releases/redmine-${finalAttrs.version}.tar.gz";
    hash = "sha256-hX6fiGDDHkxTE4nl2T7qJkiNummDBISjsKqQS+YV6Qo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    rubyEnv
    rubyEnv.wrappedRuby
    rubyEnv.bundler
  ];

  buildPhase = ''
    mv config config.dist
    mv themes themes.dist
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp -r . $out/share/redmine
    mkdir $out/share/redmine/public/assets
    for i in config files log plugins public/assets public/plugin_assets themes tmp; do
      rm -rf $out/share/redmine/$i
      ln -fs /run/redmine/$i $out/share/redmine/$i
    done

    makeWrapper ${rubyEnv.wrappedRuby}/bin/ruby $out/bin/rdm-mailhandler.rb --add-flags $out/share/redmine/extra/mail_handler/rdm-mailhandler.rb
  '';

  passthru.tests.redmine = nixosTests.redmine;

  meta = {
    homepage = "https://www.redmine.org/";
    changelog = "https://www.redmine.org/projects/redmine/wiki/changelog";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      aanderse
      felixsinger
      megheaiulian
    ];

    platforms = lib.platforms.linux;
  };
})
