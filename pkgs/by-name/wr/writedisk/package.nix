{
  lib,
  fetchCrate,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "writedisk";
  version = "1.3.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-MZFnNb8rJMu/nlH8rfnD//bhqPSkhyXucbTrwsRM9OY=";
    pname = "writedisk";
  };

  nativeBuildInputs = [ pkg-config ];
  cargoHash = "sha256-2Vc0vCQJY2enwTAgaRgqLdCTtF5znrF3xaCTvF44XX0=";

  meta = {
    description = "Small utility for writing a disk image to a USB drive";
    homepage = "https://github.com/nicholasbishop/writedisk";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ devhell ];
    platforms = lib.platforms.linux;
  };
})
