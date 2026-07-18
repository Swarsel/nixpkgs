{
  lib,
  alsa-lib,
  buildGoModule,
  fetchzip,
  pkg-config,
}:
buildGoModule {
  pname = "termsonic";
  version = "0-unstable-2025-01-07";

  src = fetchzip {
    url = "https://git.sixfoisneuf.fr/termsonic/snapshot/termsonic-1dd63d453b109c79967726106035cda9744bbe11.zip";
    hash = "sha256-HPI4G+bGHejTwVsb8YIU6b7KnIrkqzDf8zZQAWmcfks=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ];
  vendorHash = "sha256-+v7i69b4d11IGnraE6ROscFmqCVLHnkyI2pW+NS1v8k=";

  meta = {
    description = "Subsonic client running in your terminal";
    homepage = "https://git.sixfoisneuf.fr/termsonic";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.unix;
    mainProgram = "termsonic";
  };
}
