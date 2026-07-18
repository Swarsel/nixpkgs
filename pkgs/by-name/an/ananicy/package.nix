{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  python3,
  schedtool,
  sysctl,
  util-linux,
}:

stdenv.mkDerivation {
  pname = "ananicy";
  version = "unstable-2023-03-21";

  src = fetchFromGitHub {
    owner = "nefelim4ag";
    repo = "ananicy";
    rev = "1e2cc9a62ba3b6793e59da66aa0039f89e1ad49f";
    sha256 = "sha256-nHp47eYI36edka+cBMzayPHEflAzpgLx0VehhsyYpwI=";
  };

  patches = [
    # https://github.com/Nefelim4ag/Ananicy/pull/437
    # fix makefile destinations
    (fetchpatch {
      # only used for debian packaging. lets exclude it so the patch applies even when that file is changed
      excludes = [ "package.sh" ];
      sha256 = "sha256-vMcJxekg2QUbm253CLAv3tmo5kedSlw+/PI/LamNWwc=";
      url = "https://github.com/Nefelim4ag/Ananicy/commit/dbda0f50670de3f249991706ef1cc107c5197a2f.patch";
    })
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  makeFlags = [
    "PREFIX=$(out)"
    "SYSCONFDIR=${placeholder "out"}/etc"
  ];

  postInstall = ''
    wrapProgram $out/bin/ananicy \
      --prefix PATH : ${
        lib.makeBinPath [
          schedtool
          util-linux
        ]
      }

    substituteInPlace $out/lib/systemd/system/ananicy.service \
      --replace "/sbin/sysctl" "${sysctl}/bin/sysctl" \
      --replace "/usr/bin/ananicy" "$out/bin/ananicy"
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Another auto nice daemon, with community rules support";
    homepage = "https://github.com/Nefelim4ag/Ananicy";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
    mainProgram = "ananicy";
  };
}
