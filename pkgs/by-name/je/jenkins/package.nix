{
  lib,
  fetchurl,
  cacert,
  common-updater-scripts,
  coreutils,
  curl,
  git,
  gnused,
  jdk25,
  jq,
  makeWrapper,
  nix,
  nixosTests,
  stdenvNoCC,
  writeScript,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jenkins";
  version = "2.568.1";

  src = fetchurl {
    url = "https://get.jenkins.io/war-stable/${finalAttrs.version}/jenkins.war";
    hash = "sha256-WPJPOWX773cIYp++FY1RvxOP/Vd8rbyGtGNn6K0L64M=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p "$out/bin" "$out/share" "$out/webapps"

    cp "$src" "$out/webapps/jenkins.war"

    # Create the `jenkins-cli` command.
    ${jdk25}/bin/jar -xf "$src" WEB-INF/lib/cli-${finalAttrs.version}.jar \
      && mv WEB-INF/lib/cli-${finalAttrs.version}.jar "$out/share/jenkins-cli.jar"

    makeWrapper "${jdk25}/bin/java" "$out/bin/jenkins-cli" \
      --add-flags "-jar $out/share/jenkins-cli.jar"
  '';

  passthru = {
    tests = { inherit (nixosTests) jenkins jenkins-cli; };

    updateScript = writeScript "update.sh" ''
      #!${stdenvNoCC.shell}
      set -o errexit
      PATH=${
        lib.makeBinPath [
          cacert
          common-updater-scripts
          coreutils
          curl
          git
          gnused
          jq
          nix
        ]
      }

      core_json="$(curl -s --fail --location https://updates.jenkins.io/stable/update-center.actual.json | jq .core)"
      oldVersion=$(nix-instantiate --eval -E "with import ./. {}; lib.getVersion jenkins" | tr -d '"')

      version="$(jq -r .version <<<$core_json)"
      sha256="$(jq -r .sha256 <<<$core_json)"
      hash="$(nix --extra-experimental-features nix-command hash to-sri --type sha256 "$sha256")"

      if [ ! "$oldVersion" = "$version" ]; then
        update-source-version jenkins "$version" "$hash"
      else
        echo "jenkins is already up-to-date"
      fi
    '';
  };

  meta = {
    description = "Extendable open source continuous integration server";
    homepage = "https://jenkins.io/";
    changelog = "https://www.jenkins.io/changelog-stable/#v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      earldouglas
      felixsinger
    ];

    platforms = lib.platforms.all;
    mainProgram = "jenkins-cli";
  };
})
