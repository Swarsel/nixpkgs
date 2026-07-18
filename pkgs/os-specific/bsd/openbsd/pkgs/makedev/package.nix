{
  m4,
  mkDerivation,
  runtimeShell,
}:

mkDerivation {
  pname = "MAKEDEV";
  patches = [ ./bash.patch ];

  preBuild = ''
    mkdir -p $out/share/doc
  '';

  # patch some build artifacts
  # gnu m4 doesn't seem to recognize the expr() macro but it's only used for simple arithmetic so we convert it to bash
  postBuild = ''
    substituteInPlace etc.$TARGET_MACHINE_ARCH/MAKEDEV --replace-fail "/bin/sh -" "${runtimeShell}"
    sed -E -i -e '/^PATH=.*/d' -e 's/expr\((.*)\)/$((\1))/g' etc.$TARGET_MACHINE_ARCH/MAKEDEV
  '';

  # The install procedure is also weird since this is supposed to live in /dev
  postInstall = ''
    mkdir -p $out/bin
    cp etc.$TARGET_MACHINE_ARCH/MAKEDEV $out/bin
    chmod +x $out/bin/MAKEDEV
  '';

  buildTargets = [ "MAKEDEV" ];

  extraNativeBuildInputs = [
    m4
  ];

  path = "etc";
  meta.mainProgram = "MAKEDEV";
}
