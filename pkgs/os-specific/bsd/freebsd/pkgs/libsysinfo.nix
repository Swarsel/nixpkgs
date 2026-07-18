{
  lib,
  fetchurl,
  fetchFromGitHub,
  mkDerivation,
}:
let
  pcFile = fetchurl {
    hash = "sha256-KeCOYLCYeoJm+AwaagygKve2f+jNaIfaO7c/UnMegAg=";
    url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/a613e66a54d54251878412b74c1e99defdac4192/devel/libsysinfo/files/libsysinfo.pc.in";
  };
in
mkDerivation rec {
  pname = "libsysinfo";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "bsdimp";
    repo = "libsysinfo";
    rev = "e535d95d1598932a0084a027402104d6e0276479";
    hash = "sha256-HFgaYRR9HQM0iVJBWq1nrPGZIl/Y/5C0JJUunlzCZLI=";
  };

  outputs = [
    "out"
    "man"
    "debug"
  ];

  # bash-sh syntax differences
  postPatch = ''
    substituteInPlace Makefile --replace-fail 'then else' 'then :; else'
    substituteInPlace Makefile --replace-fail 'mkdir' 'mkdir -p'
  '';

  env.NIX_LDFLAGS = "-lkvm";

  postInstall = ''
    mkdir -p $out/lib/pkgconfig
    substitute ${pcFile} $out/lib/pkgconfig/libsysinfo.pc \
      --replace-fail '%%PREFIX%%' "$out" \
      --replace-fail '%%COMMENT%%' "${meta.description}" \
      --replace-fail '%%PORTVERSION%%' "${version}"

    mkdir -p $out/include/sys
    ln -s ../sysinfo.h $out/include/sys/sysinfo.h
  '';

  path = "...";

  meta = {
    description = "GNU libc's sysinfo port for FreeBSD";
    homepage = "https://github.com/bsdimp/libsysinfo";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rhelmot ];
    platforms = lib.platforms.freebsd;
  };
}
