{
  lib,
  fetchzip,
  stdenvNoCC,
  dict-type ? "core",
}:

let
  pname = "sudachidict";
  version = "20260428";

  srcs = {
    core = fetchzip {
      hash = "sha256-CTsSxUa+daLpoNDr4kIVhzAM6E1k3ZwvAhE7Lccm4YM=";
      url = "https://github.com/WorksApplications/SudachiDict/releases/download/v${version}/sudachi-dictionary-${version}-core.zip";
    };

    full = fetchzip {
      hash = "sha256-XG7zusuqDYl5q6OERDLwd9M7N7iZEvIgIuCkEhVMZiw=";
      url = "https://github.com/WorksApplications/SudachiDict/releases/download/v${version}/sudachi-dictionary-${version}-full.zip";
    };

    small = fetchzip {
      hash = "sha256-okLmQST77Iz/MkdcuhZ+Q+SDlgcM0bXTR4KNKqPHIlg=";
      url = "https://github.com/WorksApplications/SudachiDict/releases/download/v${version}/sudachi-dictionary-${version}-small.zip";
    };
  };
in

lib.checkListOfEnum "${pname}: dict-type" [ "core" "full" "small" ] [ dict-type ]

  stdenvNoCC.mkDerivation
  {
    inherit pname version;
    src = srcs.${dict-type};

    installPhase = ''
      runHook preInstall

      install -Dm644 system_${dict-type}.dic $out/share/system.dic

      runHook postInstall
    '';

    dontBuild = true;
    dontConfigure = true;

    passthru = {
      dict-type = dict-type;
      updateScript = ./update.sh;
    };

    meta = {
      description = "Lexicon for Sudachi";
      homepage = "https://github.com/WorksApplications/SudachiDict";
      changelog = "https://github.com/WorksApplications/SudachiDict/releases/tag/v${version}";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ natsukium ];
      platforms = lib.platforms.all;
      # it is a waste of space and time to build this package in hydra since it is just data
      hydraPlatforms = [ ];
    };
  }
