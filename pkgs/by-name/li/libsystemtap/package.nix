{
  lib,
  stdenv,
  elfutils,
  fetchgit,
  gettext,
  python3,
}:

stdenv.mkDerivation {
  pname = "libsystemtap";
  version = "5.3";

  src = fetchgit {
    url = "git://sourceware.org/git/systemtap.git";
    rev = "release-5.3";
    hash = "sha256-W9iJ+hyowqgeq1hGcNQbvPfHpqY0Yt2W/Ng/4p6asxc=";
  };

  nativeBuildInputs = [
    gettext
    python3
  ];

  buildInputs = [ elfutils ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/include
    cp -r includes/* $out/include/

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Statically defined probes development files";
    homepage = "https://sourceware.org/systemtap/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.workflow ];
    platforms = elfutils.meta.platforms or lib.platforms.unix;
    badPlatforms = elfutils.meta.badPlatforms or [ ];
  };
}
