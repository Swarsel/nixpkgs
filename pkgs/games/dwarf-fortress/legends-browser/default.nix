{
  lib,
  fetchurl,
  buildEnv,
  jre,
  writeShellScriptBin,
}:

let
  version = "1.19.2";

  jar = fetchurl {
    hash = "sha256-jkv7InwaRn0K3VAa0LqkYpH6TnrT/tGYBtbvNGM6t98=";
    url = "https://github.com/robertjanetzko/LegendsBrowser/releases/download/${version}/legendsbrowser-${version}.jar";
  };

  script = writeShellScriptBin "legends-browser" ''
    set -eu
    BASE="$HOME/.local/share/df_linux/legends-browser/"
    mkdir -p "$BASE"
    cd "$BASE"
    if [[ ! -e legendsbrowser.properties ]]; then
      echo 'Creating initial configuration for legends-browser'
      echo "last=$(cd ..; pwd)" > legendsbrowser.properties
    fi
    exec ${jre}/bin/java -jar ${jar}
  '';
in

buildEnv {
  inherit version;
  pname = "legends-browser";
  paths = [ script ];

  meta = {
    description = "Multi-platform, open source, java-based legends viewer for dwarf fortress";
    homepage = "https://github.com/robertjanetzko/LegendsBrowser";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      Baughn
      numinit
    ];

    platforms = lib.platforms.all;
  };
}
