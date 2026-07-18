{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  notmuch,
  pkg-config,
}:

let
  version = "10";
in
stdenv.mkDerivation {
  inherit version;
  pname = "notmuch-addrlookup";

  src = fetchFromGitHub {
    owner = "aperezdc";
    repo = "notmuch-addrlookup-c";
    rev = "v${version}";
    sha256 = "sha256-Z59MAptJw95azdK0auOuUyxBrX4PtXwnRNPkhjgI6Ro=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    notmuch
  ];

  installPhase = "install -D notmuch-addrlookup $out/bin/notmuch-addrlookup";

  meta = {
    description = "Address lookup tool for Notmuch in C";
    homepage = "https://github.com/aperezdc/notmuch-addrlookup-c";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mog ];
    platforms = lib.platforms.unix;
    mainProgram = "notmuch-addrlookup";
  };
}
