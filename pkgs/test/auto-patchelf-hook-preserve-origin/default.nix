{
  lib,
  stdenv,
  autoPatchelfHook,
  patchelf,
  tests,
}:

let
  foo = tests.stdenv-inputs.foo;
  bar = tests.stdenv-inputs.bar;

  # similar to lib-check in stdenv-inputs, but we ship
  # binary and libraries in the same output, and only
  # $ORIGIN/../lib in RUNPATH.
  lib-check = stdenv.mkDerivation {
    nativeBuildInputs = [
      patchelf
    ];

    buildInputs = [
      foo
      bar
    ];

    buildCommand = ''
      $CC -lfoo -lbar -Wl,-rpath,'$ORIGIN/../lib' -o lib-check ${./lib-main.c}

      # Shrink RUNPATH to only keep the $ORIGIN/../lib one,
      # dropping references to foo and bar store path.
      patchelf --shrink-rpath --allowed-rpath-prefixes '$ORIGIN/../lib' lib-check


      mkdir -p $out/lib $out/bin
      cp ${lib.getDev foo}/lib/* ${lib.getDev bar}/lib/* $out/lib/
      cp lib-check $out/bin/

      # Make sure the binary still works
      $out/bin/lib-check
    '';

    disallowedReferences = [
      (lib.getDev foo)
      (lib.getDev bar)
    ];

    name = "lib-check-bundle";
  };
  # We treat `lib-check` as binaries and libraries coming from somewhere,
  # and run `autoPatchelfHook` on them, but setting `--preserve-origin`.
  # If we wouldn't,`autoPatchelfHook` would replace `RUNPATH` with a
  # (self-)reference.
  lib-check-autopatchelfed = stdenv.mkDerivation {
    nativeBuildInputs = [
      autoPatchelfHook
    ];

    # we don't set buildCommand because we want to ensure fixupPhase
    # (containing autoPatchelfHook) is run.
    installPhase = ''
      mkdir -p $out
      cp -R ${lib-check}/* $out
    '';

    autoPatchelfFlags = [ "--preserve-origin" ];

    # Should not refer to our source nor to itself.
    disallowedReferences = [
      lib-check
      "out"
    ];

    dontUnpack = true;
    name = "lib-check-autopatchelfed";
  };
in
stdenv.mkDerivation {
  buildCommand = ''
    # Ensure the binary still works
    ${lib-check-autopatchelfed}/bin/lib-check
    touch $out
  '';

  name = "auto-patchelf-hook-preserve-origin";

  passthru = {
    inherit lib-check lib-check-autopatchelfed;
  };

  meta.platforms = lib.platforms.all;
}
