{
  lib,
  stdenv,
  fetchFromSourcehut,
  gitUpdater,
  hareHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hare-ev";
  version = "0.26.0.0";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "hare-ev";
    tag = finalAttrs.version;
    hash = "sha256-Chetww+F46ZJ+cgVuoFXRVYOT9g13iBK5EembWXQhuc=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  doCheck = true;
  nativeCheckInputs = [ hareHook ];
  passthru.updateScript = gitUpdater { };

  meta = {
    inherit (hareHook.meta) platforms badPlatforms;
    description = "Event loop for Hare programs";
    homepage = "https://sr.ht/~sircmpwn/hare-ev";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
