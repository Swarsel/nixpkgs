{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:

{
  pname,
  version,
  zipHash,
  meta ? { },
  passthru ? { },
  versionPrefix ? "",
  ...
}@args:
let
  plat = stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation (
  {
    inherit pname versionPrefix version;

    src =
      if lib.isAttrs zipHash then
        fetchurl {
          url =
            "https://grafana.com/api/plugins/${pname}/versions/${versionPrefix}${version}/download"
            + {
              aarch64-darwin = "?os=darwin&arch=arm64";
              aarch64-linux = "?os=linux&arch=arm64";
              x86_64-linux = "?os=linux&arch=amd64";
            }
            .${plat} or (throw "Unsupported system: ${plat}");

          hash = zipHash.${plat} or (throw "Unsupported system: ${plat}");
          name = "${pname}-${versionPrefix}${version}-${plat}.zip";
        }
      else
        fetchurl {
          url = "https://grafana.com/api/plugins/${pname}/versions/${versionPrefix}${version}/download";
          hash = zipHash;
          name = "${pname}-${versionPrefix}${version}.zip";
        };

    nativeBuildInputs = [ unzip ];

    installPhase = ''
      cp -R "." "$out"
      chmod -R a-w "$out"
      chmod u+w "$out"
    '';

    passthru = {
      updateScript = [
        ./update-grafana-plugin.sh
        pname
      ];
    }
    // passthru;

    meta = {
      homepage = "https://grafana.com/grafana/plugins/${pname}";
    }
    // meta;
  }
  // (removeAttrs args [
    "zipHash"
    "pname"
    "versionPrefix"
    "version"
    "sha256"
    "meta"
  ])
)
