{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoc-full,
  attr,
  fuse3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "disorderfs";
  version = "0.6.2";

  src = fetchFromGitLab {
    owner = "reproducible-builds";
    repo = "disorderfs";
    tag = finalAttrs.version;
    hash = "sha256-1ehGbNYbOewnDrQ1JhozKMvfVaCH7sDCxrD0dvwAfw0=";
    domain = "salsa.debian.org";
  };

  nativeBuildInputs = [
    pkg-config
    asciidoc-full
  ];

  buildInputs = [
    fuse3
    attr
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Overlay FUSE filesystem that introduces non-determinism into filesystem metadata";
    homepage = "https://salsa.debian.org/reproducible-builds/disorderfs";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    mainProgram = "disorderfs";
  };
})
