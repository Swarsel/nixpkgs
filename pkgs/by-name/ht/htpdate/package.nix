{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "htpdate";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "twekkel";
    repo = "htpdate";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-aDir0e/itYxo0wgKIyT2chEVyXgz6nd2JOuyo7Yq/js=";
  };

  makeFlags = [
    "prefix=$(out)"
  ];

  meta = {
    description = "Utility to fetch time and set the system clock over HTTP";
    homepage = "https://github.com/twekkel/htpdate";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ julienmalka ];
    platforms = lib.platforms.linux;
    mainProgram = "htpdate";
  };
})
