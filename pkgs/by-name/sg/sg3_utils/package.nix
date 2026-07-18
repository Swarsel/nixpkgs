{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sg3_utils";
  version = "1.48";

  src = fetchurl {
    url = "https://sg.danny.cz/sg/p/sg3_utils-${finalAttrs.version}.tgz";
    sha256 = "sha256-1itsPPIDkPpzVwRDkAhBZtJfHZMqETXEULaf5cKD13M=";
  };

  outputs = [
    "out"
    "man"
    "dev"
    "lib"
  ];

  postPatch = ''
    substituteInPlace scripts/rescan-scsi-bus.sh \
      --replace-fail '/usr/bin/sg_' "$out/bin/sg_"
  '';

  meta = {
    description = "Utilities that send SCSI commands to devices";
    homepage = "https://sg.danny.cz/sg/";
    changelog = "https://sg.danny.cz/sg/p/sg3_utils.ChangeLog";

    license = with lib.licenses; [
      bsd2
      gpl2Plus
    ];

    platforms = lib.platforms.linux;
  };
})
