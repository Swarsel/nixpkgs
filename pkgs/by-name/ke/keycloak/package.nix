{
  lib,
  stdenv,
  callPackage,
  fetchzip,
  jre_headless,
  makeBinaryWrapper,
  nixosTests,
  confFile ? null,
  disabledFeatures ? [ ],
  extraFeatures ? [ ],
  plugins ? [ ],
}:

let
  featuresSubcommand = ''
    ${
      lib.optionalString (extraFeatures != [ ]) "--features=${lib.concatStringsSep "," extraFeatures}"
    } \
    ${lib.optionalString (
      disabledFeatures != [ ]
    ) "--features-disabled=${lib.concatStringsSep "," disabledFeatures}"}
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "keycloak";
  version = "26.7.0";

  src = fetchzip {
    url = "https://github.com/keycloak/keycloak/releases/download/${finalAttrs.version}/keycloak-${finalAttrs.version}.zip";
    hash = "sha256-QfPCgwUZYwiCWZgL8DVlVAYE3AoZnDHn99j+f/oo0Hs=";
  };

  patches = [
    # Make home.dir and config.dir configurable through the
    # KC_HOME_DIR and KC_CONF_DIR environment variables.
    ./config_vars.patch
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    jre_headless
  ];

  buildPhase = ''
    runHook preBuild
  ''
  + lib.optionalString (confFile != null) ''
    install -m 0600 ${confFile} conf/keycloak.conf
  ''
  + ''
    install_plugin() {
      if [ -d "$1" ]; then
        find "$1" -type f \( -iname \*.ear -o -iname \*.jar \) -exec install -p -m 0500 "{}" "providers/" \;
      else
        install -p -m 0500 "$1" "providers/"
      fi
    }
    ${lib.concatMapStringsSep "\n" (pl: "install_plugin ${lib.escapeShellArg pl}") plugins}
  ''
  + ''
    patchShebangs bin/kc.sh
    export KC_HOME_DIR=$(pwd)
    export KC_CONF_DIR=$(pwd)/conf
    bin/kc.sh build ${featuresSubcommand}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out

    rm $out/bin/*.{ps1,bat,orig}

    runHook postInstall
  '';

  postFixup = ''
    for script in $(find $out/bin -type f -executable); do
      wrapProgram "$script" --set JAVA_HOME ${jre_headless} --prefix PATH : ${jre_headless}/bin
    done
  '';

  passthru = {
    enabledPlugins = plugins;
    plugins = callPackage ./all-plugins.nix { };
    tests = nixosTests.keycloak;
  };

  meta = {
    description = "Identity and access management for modern applications and services";
    homepage = "https://www.keycloak.org/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      ngerstle
      talyz
      nickcao
      leona
      anish
      krit
      jefferyoo
    ];

    platforms = jre_headless.meta.platforms;
  };
})
