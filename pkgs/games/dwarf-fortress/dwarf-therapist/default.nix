{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dfVersions,
  ninja,
  qtbase,
  qtdeclarative,
  hash ? dfVersions.therapist.git.outputHash,
  maxDfVersion ? dfVersions.therapist.maxDfVersion,
  # see: https://github.com/Dwarf-Therapist/Dwarf-Therapist/releases
  version ? dfVersions.therapist.version,
}:

stdenv.mkDerivation rec {
  inherit version;
  pname = "dwarf-therapist";

  src = fetchFromGitHub {
    inherit hash;
    owner = "Dwarf-Therapist";
    repo = "Dwarf-Therapist";
    tag = "v${version}";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    qtbase
    qtdeclarative
  ];

  cmakeFlags = [ "-GNinja" ];

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications
        cp -r DwarfTherapist.app $out/Applications
      ''
    else
      null;

  dontWrapQtApps = true;
  enableParallelBuilding = true;

  passthru = {
    inherit maxDfVersion;
  };

  meta = {
    description = "Tool to manage dwarves in a running game of Dwarf Fortress";
    homepage = "https://github.com/Dwarf-Therapist/Dwarf-Therapist";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bendlas
      numinit
    ];

    platforms = lib.platforms.x86;
    mainProgram = "dwarftherapist";
  };
}
