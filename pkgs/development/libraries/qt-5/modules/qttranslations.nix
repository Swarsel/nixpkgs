{ qtModule, qttools }:

qtModule {
  pname = "qttranslations";
  outputs = [ "out" ];
  nativeBuildInputs = [ qttools ];
}
