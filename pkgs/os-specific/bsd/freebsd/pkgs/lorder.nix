{
  bsdSetupHook,
  freebsdSetupHook,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
  ];

  buildInputs = [ ];

  installPhase = ''
    mkdir -p "$out/bin" "$man/share/man"
    mv "lorder.sh" "$out/bin/lorder"
    chmod +x "$out/bin/lorder"
    mv "lorder.1" "$man/share/man"
  '';

  dontBuild = true;
  noCC = true;
  path = "usr.bin/lorder";
}
