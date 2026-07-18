{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  makeWrapper,
  xauth,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xtrace";
  version = "1.4.0";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "xtrace";
    rev = "xtrace-${finalAttrs.version}";
    sha256 = "1yff6x847nksciail9jly41mv70sl8sadh0m5d847ypbjmxcwjpq";
    domain = "salsa.debian.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [ libx11 ];

  postInstall = ''
    wrapProgram "$out/bin/xtrace" \
        --prefix PATH ':' "${xauth}/bin"
  '';

  meta = {
    description = "Tool to trace X11 protocol connections";
    homepage = "https://salsa.debian.org/debian/xtrace";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "xtrace";
  };
})
