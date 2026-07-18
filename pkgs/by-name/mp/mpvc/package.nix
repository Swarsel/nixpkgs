{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  socat,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpvc";
  version = "1.4-unstable-2024-07-09";

  src = fetchFromGitHub {
    owner = "gmt4";
    repo = "mpvc";
    rev = "966156dacd026cde220951d41c4ac5915cd6ad64";
    hash = "sha256-/M3xOb0trUaxJGXmV2+sOCbrHGyP4jpyo+S/oBoDkO0=";
  };

  outputs = [
    "out"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ socat ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/mpvc --prefix PATH : "${lib.getBin socat}/"
  '';

  # This is not Archlinux :)
  postFixup = ''
    rm -r $out/share/licenses
    rmdir $out/share || true
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Mpc-like control interface for mpv";
    homepage = "https://github.com/gmt4/mpvc";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "mpvc";
  };
})
