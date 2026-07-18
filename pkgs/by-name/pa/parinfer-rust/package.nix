{
  lib,
  fetchFromGitHub,
  llvmPackages,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "parinfer-rust";
  version = "0.4.3-unstable-2024-05-07";

  src = fetchFromGitHub {
    owner = "eraserhd";
    repo = "parinfer-rust";
    rev = "d84828b453e158d06406f6b5e9056f6b54ff76c9";
    sha256 = "sha256-Q2fYogfn5QcNDEie4sUaVydAmDmcFXnsvz35cxPCf+M=";
  };

  nativeBuildInputs = [
    llvmPackages.clang
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-w/GMjNtKiMGYOfzSl5IZTeHBSp4C9Mu6+oogCqHxdb4=";

  postInstall = ''
    mkdir -p $out/share/kak/autoload/plugins
    cp rc/parinfer.kak $out/share/kak/autoload/plugins/

    rtpPath=$out/plugin
    mkdir -p $rtpPath
    sed "s,let s:libdir = .*,let s:libdir = '${placeholder "out"}/lib'," \
      plugin/parinfer.vim > $rtpPath/parinfer.vim
  '';

  meta = {
    description = "Infer parentheses for Clojure, Lisp, and Scheme";
    homepage = "https://github.com/eraserhd/parinfer-rust";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ eraserhd ];
    mainProgram = "parinfer-rust";
  };
}
