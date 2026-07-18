{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  pbcopy ? null,
  useGeoIP ? false, # Require /var/lib/geoip-databases/GeoIP.dat
  x11Support ? !stdenv.hostPlatform.isDarwin,
  xclip ? null,
}:
let
  version = "0.9.6";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "tremc";

  src = fetchFromGitHub {
    owner = "tremc";
    repo = "tremc";
    tag = version;
    hash = "sha256-GbQ1x973M9sP9360gEzCypU7JlxwH/Uo/tUUQRlNfC8=";
  };

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];
  doCheck = false;
  dontBuild = true;

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath (lib.optional x11Support xclip ++ lib.optional stdenv.hostPlatform.isDarwin pbcopy)
    }"
  ];

  pyproject = false;

  pythonPath =
    with python3Packages;
    [
      ipy
      pyperclip
    ]
    ++ lib.optional useGeoIP geoip;

  meta = {
    description = "Curses interface for transmission";
    homepage = "https://github.com/tremc/tremc";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kashw2 ];
    mainProgram = "tremc";
  };
}
