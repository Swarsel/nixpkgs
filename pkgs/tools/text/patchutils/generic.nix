{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  perl,
  sha256,
  version,
  extraBuildInputs ? [ ],
  patches ? [ ],
  ...
}:
stdenv.mkDerivation rec {
  inherit version patches;
  pname = "patchutils";

  src = fetchurl {
    inherit sha256;
    url = "https://cyberelk.net/tim/data/patchutils/stable/${pname}-${version}.tar.xz";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ] ++ extraBuildInputs;

  preConfigure = ''
    export PERL=${perl.interpreter}
  '';

  doCheck = lib.versionAtLeast version "0.3.4";

  preCheck = ''
    patchShebangs tests
    chmod +x scripts/*
  ''
  + lib.optionalString (lib.versionOlder version "0.4.2") ''
    find tests -type f -name 'run-test' \
      -exec sed -i '{}' -e 's|/bin/echo|echo|g' \;
  '';

  postInstall = ''
    for bin in $out/bin/{splitdiff,rediff,editdiff,dehtmldiff}; do
      wrapProgram "$bin" \
        --prefix PATH : "$out/bin"
    done
  '';

  # tests fail when building in parallel
  enableParallelBuilding = false;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Tools to manipulate patch files";
    homepage = "http://cyberelk.net/tim/software/patchutils";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.all;
  };
}
