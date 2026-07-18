{
  lib,
  stdenv,
  fetchFromSourcehut,
  hareHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hare-ssh";
  version = "0.26.0";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "hare-ssh";
    tag = finalAttrs.version;
    hash = "sha256-msPY8m7/GDKsGDrhZ1IK65U+6fcI26FW9CONC4w87Pg=";
  };

  nativeBuildInputs = [ hareHook ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  doCheck = true;

  meta = {
    inherit (hareHook.meta) platforms badPlatforms;
    description = "SSH client & server protocol implementation for Hare";
    homepage = "https://git.sr.ht/~sircmpwn/hare-ssh/";
    license = with lib.licenses; [ mpl20 ];
    maintainers = with lib.maintainers; [ patwid ];
  };
})
