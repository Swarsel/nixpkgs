{
  lib,
  stdenv,
  config,
  element-web-unwrapped,
  jq,
  conf ? config.element-web.conf or { },
}:

if (conf == { }) then
  element-web-unwrapped
else
  stdenv.mkDerivation {
    inherit (element-web-unwrapped) version meta;
    pname = "${element-web-unwrapped.pname}-wrapped";
    nativeBuildInputs = [ jq ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      ln -s ${element-web-unwrapped}/* $out
      rm $out/config.json
      jq -s '.[0] * $conf' "${element-web-unwrapped}/config.json" --argjson "conf" ${lib.escapeShellArg (builtins.toJSON conf)} > "$out/config.json"

      runHook postInstall
    '';

    dontUnpack = true;

    passthru = {
      inherit conf;
    };
  }
