{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  olm,
  # This option enables the use of an experimental pure-Go implementation of
  # the Olm protocol instead of libolm for end-to-end encryption. Using goolm
  # is not recommended by the mautrix developers, but they are interested in
  # people trying it out in non-production-critical environments and reporting
  # any issues they run into.
  withGoolm ? false,
}:

buildGoModule rec {
  pname = "mautrix-whatsapp";
  version = "26.06";

  src = fetchFromGitHub {
    inherit tag;
    owner = "mautrix";
    repo = "whatsapp";
    hash = "sha256-xxUsFrBX6wwANKECwL6ITDkc88XpCyGpWDPjGQlH3fI=";
  };

  buildInputs = lib.optional (!withGoolm) olm;
  vendorHash = "sha256-H8dSwOPVJ3TofAJDupYhX6/Vm5qshhFXaMtUDWM/0mw=";

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${tag}"
  ];

  tag = "v0.2606.0";
  tags = lib.optional withGoolm "goolm";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Matrix-WhatsApp puppeting bridge";
    homepage = "https://github.com/mautrix/whatsapp";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      vskilet
      ma27
      chvp
      SchweGELBin
    ];

    mainProgram = "mautrix-whatsapp";
  };
}
