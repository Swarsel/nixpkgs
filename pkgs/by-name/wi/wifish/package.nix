{
  lib,
  stdenv,
  fetchFromGitHub,
  dialog,
  gawk,
  makeWrapper,
  wpa_supplicant,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wifish";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "bougyman";
    repo = "wifish";
    rev = finalAttrs.version;
    sha256 = "sha256-eTErN6CfKDey/wV+9o9cBVaG5FzCRBiA9UicrMz3KBc=";
  };

  postPatch = ''
    sed -i -e 's|/var/lib/wifish|${placeholder "out"}/var/lib/wifish|' wifish
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D -m0644 awk/wscanparse.awk ${placeholder "out"}/var/lib/wifish/wscanparse.awk
    install -D -m0644 awk/wlistparse.awk ${placeholder "out"}/var/lib/wifish/wlistparse.awk
    install -D -m0644 awk/wscan2menu.awk ${placeholder "out"}/var/lib/wifish/wscan2menu.awk
    install -D -m0644 awk/iwparse.awk ${placeholder "out"}/var/lib/wifish/iwparse.awk
    install -D -m0755 wifish ${placeholder "out"}/bin/wifish
  '';

  postFixup = ''
    wrapProgram ${placeholder "out"}/bin/wifish \
      --prefix PATH ":" ${
        lib.makeBinPath [
          dialog
          gawk
          wpa_supplicant
        ]
      }
  '';

  dontConfigure = true;

  meta = {
    description = "Simple wifi shell script for linux";
    homepage = "https://github.com/bougyman/wifish";
    license = lib.licenses.wtfpl;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "wifish";
  };
})
