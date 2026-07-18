{
  lib,
  stdenv,
  fediwall-unwrapped,
  conf ? { },
}:

if (conf == { }) then
  fediwall-unwrapped
else
  stdenv.mkDerivation {
    inherit (fediwall-unwrapped) version meta;
    pname = "fediwall";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      ln -s ${fediwall-unwrapped}/* $out
      echo ${lib.escapeShellArg (builtins.toJSON conf)} \
          > "$out/wall-config.json"
      runHook postInstall
    '';

    dontUnpack = true;
  }
