{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  help2man,
  libiff,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "libilbm";
  version = "0-unstable-2024-03-02";

  src = fetchFromGitHub {
    owner = "svanderburg";
    repo = "libilbm";
    rev = "586f5822275ef5780509a851cb90c7407b2633d9";
    hash = "sha256-EcsrspL/N40yFE15UFWGienpJHhoq1zd8zZe6x4nK6o=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    help2man
  ];

  buildInputs = [ libiff ];

  meta = {
    description = "Parser for the ILBM: IFF Interleaved BitMap format";

    longDescription = ''
      libilbm is a portable parser library built on top of libiff,
      for ILBM: IFF Interleaved BitMap format, which is used by programs
      such as Deluxe Paint and Graphicraft to read and write images.
    '';

    homepage = "https://github.com/svanderburg/libilbm";
    changelog = "https://github.com/svanderburg/libilbm/blob/master/ChangeLog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _414owen ];
    platforms = lib.platforms.all;
  };
}
