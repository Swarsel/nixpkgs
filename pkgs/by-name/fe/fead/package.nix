{
  lib,
  stdenv,
  fetchzip,
  help2man,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fead";
  version = "1.0.0";

  src = fetchzip {
    url = "https://trong.loang.net/~cnx/fead/snapshot/fead-${finalAttrs.version}.tar.gz";
    hash = "sha256-cbU379Zz+mwRqEHiDUlGvWheLkkr0YidHeVs/1Leg38=";
  };

  # Needed for man page generation in build phase
  postPatch = ''
    patchShebangs src/fead.py
  '';

  nativeBuildInputs = [ help2man ];
  buildInputs = [ python3 ];
  makeFlags = [ "PREFIX=$(out)" ];
  # The package has no tests.
  doCheck = false;
  # Already done in postPatch phase
  dontPatchShebangs = true;

  meta = {
    description = "Advert generator from web feeds";
    homepage = "https://trong.loang.net/~cnx/fead";
    changelog = "https://trong.loang.net/~cnx/fead/tag?h=${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ McSinyx ];
    mainProgram = "fead";
  };
})
