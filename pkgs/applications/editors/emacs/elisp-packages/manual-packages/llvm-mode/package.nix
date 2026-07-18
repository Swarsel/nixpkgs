{ llvmPackages, melpaBuild }:

melpaBuild {
  inherit (llvmPackages.llvm) src version;
  pname = "llvm-mode";

  files = ''
    ("llvm/utils/emacs/*.el"
     "llvm/utils/emacs/README")
  '';

  meta = {
    inherit (llvmPackages.llvm.meta) homepage license;
    description = "Major mode for the LLVM assembler language";
  };
}
