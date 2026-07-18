{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg,
  vdr,
}:
stdenv.mkDerivation rec {
  pname = "vdr-markad";
  version = "4.2.22";

  src = fetchFromGitHub {
    owner = "kfb77";
    repo = "vdr-plugin-markad";
    tag = "V${version}";
    hash = "sha256-Sp9saT/w3QwLEz9mo4kMUrXMXc5S/DOxm4nN1FPEgtk=";
  };

  postPatch = ''
    substituteInPlace command/Makefile --replace '/usr' ""

    substituteInPlace plugin/markad.cpp \
      --replace "/usr/bin" "$out/bin" \
      --replace "/var/lib/markad" "$out/var/lib/markad"

    substituteInPlace command/markad-standalone.cpp \
      --replace "/var/lib/markad" "$out/var/lib/markad"
  '';

  buildInputs = [
    vdr
    ffmpeg
  ];

  buildFlags = [
    "DESTDIR=$(out)"
    "VDRDIR=${vdr.dev}/lib/pkgconfig"
  ];

  installFlags = buildFlags;

  meta = {
    inherit (src.meta) homepage;
    inherit (vdr.meta) platforms license;
    description = "Plugin for VDR that marks advertisements";
    maintainers = [ lib.maintainers.ck3d ];
    mainProgram = "markad";
  };
}
