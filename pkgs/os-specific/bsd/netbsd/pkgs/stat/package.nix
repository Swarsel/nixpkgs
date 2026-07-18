{
  bsdSetupHook,
  groff,
  install,
  makeMinimal,
  mandoc,
  mkDerivation,
  netbsdSetupHook,
}:

# Don't add this to nativeBuildInputs directly.
# Use statHook instead. See note in stat/hook.nix

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    mandoc
    groff
  ];

  path = "usr.bin/stat";
}
