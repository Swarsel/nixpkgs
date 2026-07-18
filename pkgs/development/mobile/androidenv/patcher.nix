{
  lib,
  stdenv,
  arch,
  autoPatchelfHook,
  deployAndroidPackage,
  os,
  package,
}:

deployAndroidPackage {
  inherit package os arch;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  patchInstructions = lib.optionalString (os == "linux") ''
    autoPatchelf $packageBaseDir/bin
  '';
}
