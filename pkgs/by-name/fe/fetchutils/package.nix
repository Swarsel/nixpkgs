{
  lib,
  fetchFromGitHub,
  bash,
  scdoc,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "fetchutils";
  version = "unstable-2021-03-16";

  src = fetchFromGitHub {
    owner = "kiedtl";
    repo = "fetchutils";
    rev = "882781a297e86f4ad4eaf143e0777fb3e7c69526";
    sha256 = "sha256-ONrVZC6GBV5v3TeBekW9ybZjDHF3FNyXw1rYknqKRbk=";
  };

  postPatch = ''
    patchShebangs --host src/*
  '';

  nativeBuildInputs = [
    scdoc
  ];

  buildInputs = [
    bash
  ];

  installFlags = [ "PREFIX=$(out)/" ];

  meta = {
    description = "Collection of small shell utilities to fetch system information";
    homepage = "https://github.com/lptstr/fetchutils";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moni ];
    platforms = lib.platforms.unix;
  };
}
