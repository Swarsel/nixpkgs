{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  blast,
  bzip2,
  coreutils,
  glib,
  libxml2,
  perl,
  python3,
  sqlite,
  zlib,
}:
let
  pname = "blast-bin";
  version = "2.16.0";

  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-6NpPNLBCHaBRscLZ5fjh5Dv3bjjPk2Gh2+L7xEtiJNs=";
      url = "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${version}/ncbi-blast-${version}+-aarch64-macosx.tar.gz";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-1EeiMu08R9Glq8qRky4OTT5lQPLJcM7iaqUrmUOS4MI=";
      url = "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${version}/ncbi-blast-${version}+-aarch64-linux.tar.gz";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-sLEwmMkB0jsyStFwDnRxu3QIp/f1F9dNX6rXEb526PQ=";
      url = "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${version}/ncbi-blast-${version}+-x64-linux.tar.gz";
    };
  };
  src = srcs.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    python3
    perl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    bzip2
    glib
    libxml2
    sqlite
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/* -t $out/bin

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace $out/bin/get_species_taxids.sh \
      --replace /bin/rm ${coreutils}/bin/rm
  '';

  meta = {
    inherit (blast.meta) description homepage license;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ natsukium ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
