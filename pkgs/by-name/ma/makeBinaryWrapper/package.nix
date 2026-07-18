{
  lib,
  dieHook,
  makeSetupHook,
  targetPackages,
  tests,
  writeShellScript,
  cc ? targetPackages.stdenv.cc,
  sanitizers ? [ ],
}:

makeSetupHook {
  propagatedBuildInputs = [ dieHook ];
  name = "make-binary-wrapper-hook";

  substitutions = {
    cc = "${cc}/bin/${cc.targetPrefix}cc ${
      lib.escapeShellArgs (map (s: "-fsanitize=${s}") sanitizers)
      + lib.optionalString (
        cc.isClang && !cc.stdenv.hostPlatform.isDarwin
      ) "--ld-path=${cc.targetPrefix}ld"
    }";
  };

  passthru = {
    # Extract the function call used to create a binary wrapper from its embedded docstring
    extractCmd = writeShellScript "extract-binary-wrapper-cmd" ''
      ${targetPackages.gnuStdenv.cc.bintools.targetPrefix}strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
    '';

    tests = tests.makeBinaryWrapper;
  };

  meta.license = lib.licenses.mit;
} ./make-binary-wrapper.sh
