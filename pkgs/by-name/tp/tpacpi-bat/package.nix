{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  kmod,
  perl,
}:

# Requires the acpi_call kernel module in order to run.
stdenv.mkDerivation (finalAttrs: {
  pname = "tpacpi-bat";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "teleshoes";
    repo = "tpacpi-bat";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9XnvVNdgB5VeI3juZfc8N5weEyULXuqu1IDChZfQqFk=";
  };

  postPatch = ''
    substituteInPlace tpacpi-bat \
      --replace modprobe ${kmod}/bin/modprobe \
      --replace cat ${coreutils}/bin/cat
  '';

  buildInputs = [ perl ];

  installPhase = ''
    mkdir -p $out/bin
    cp tpacpi-bat $out/bin
  '';

  meta = {
    description = "Tool to set battery charging thresholds on Lenovo Thinkpad";
    homepage = "https://github.com/teleshoes/tpacpi-bat";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.orbekk ];
    platforms = lib.platforms.linux;
    mainProgram = "tpacpi-bat";
  };
})
