{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  bashNonInteractive,
  cron,
  fuse3,
  gettext,
  gnugrep,
  gocryptfs,
  makeWrapper,
  man,
  openssh,
  ps,
  python3,
  rsync,
  sshfs-fuse,
  which,
}:

let
  python' = python3.withPackages (
    ps: with ps; [
      dbus-python
      keyring
      packaging
    ]
  );

  apps = lib.makeBinPath [
    openssh
    python'
    cron
    rsync
    sshfs-fuse
    gocryptfs
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "backintime-common";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "bit-team";
    repo = "backintime";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/33Lx62S/9RcqrfJumE6/o3KnAObBa3DcmuGkcOXIQE=";
  };

  outputs = [
    "out"
    "man"
    "doc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    gettext
    asciidoctor
    man
  ];

  buildInputs = [
    python'
    bashNonInteractive
  ];

  configureFlags = [ "--python=${lib.getExe python'}" ];

  preConfigure = ''
    patchShebangs --build updateversion.sh
    patchShebangs --build doc/manpages/build_manpages.sh
    cd common
    substituteInPlace configure \
      --replace-fail "/../etc" "/etc" \
      --replace-fail "share/backintime" "${python'.sitePackages}/backintime"

    substituteInPlace "backintime" "backintime-askpass" \
      --replace-fail "share" "${python'.sitePackages}"

    substituteInPlace "schedule.py" \
      --replace-fail "'crontab'" "'${lib.getExe' cron "crontab"}'" \
      --replace-fail "'which'" "'${lib.getExe which}'" \
      --replace-fail "'ps'" "'${lib.getExe ps}'" \
      --replace-fail "'grep'" "'${lib.getExe gnugrep}'" \

    substituteInPlace mount.py \
      --replace-fail "'fusermount'" "'${lib.getExe' fuse3 "fusermount3"}'"

    substituteInPlace "bitlicense.py" \
      --replace-fail "/usr/share/doc" "$doc/share/doc" \
  '';

  preFixup = ''
    wrapProgram "$out/bin/backintime" \
      --prefix PATH : ${apps}
  '';

  __structuredAttrs = true;
  dontAddPrefix = true;
  enableParallelBuilding = true;
  installFlags = [ "DEST=$(out)" ];

  meta = {
    description = "Simple backup tool for Linux";

    longDescription = ''
      Back In Time is a simple backup tool (on top of rsync) for Linux
      inspired from "flyback project" and "TimeVault". The backup is
      done by taking snapshots of a specified set of directories.
    '';

    homepage = "https://github.com/bit-team/backintime";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ stephen-huan ];
    platforms = lib.platforms.linux;
    mainProgram = "backintime";
  };
})
