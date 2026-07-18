{
  bootstrapFiles,
  extraAttrs,
  system,
}:

derivation (
  {
    inherit system;

    args = [
      "ash"
      "-e"
      ./musl/unpack-bootstrap-tools.sh
    ];

    builder = bootstrapFiles.busybox;

    hardeningUnsupportedFlags = [
      "fortify3"
      "shadowstack"
      "pacret"
      "zerocallusedregs"
      "trivialautovarinit"
    ];

    isGNU = true;
    # Needed by the GCC wrapper.
    langC = true;
    langCC = true;
    name = "bootstrap-tools";
    tarball = bootstrapFiles.bootstrapTools;
  }
  // extraAttrs
)
