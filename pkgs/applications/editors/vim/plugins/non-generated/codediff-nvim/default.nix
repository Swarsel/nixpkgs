{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cmake,
  llvmPackages,
  nix-update-script,
  vimPlugins,
  vimUtils,
}:
vimUtils.buildVimPlugin rec {
  pname = "codediff.nvim";
  version = "2.49.2";

  src = fetchFromGitHub {
    owner = "esmuellert";
    repo = "codediff.nvim";
    tag = "v${version}";
    hash = "sha256-kT5plTJP4VfN6mFkq6voDTmr9LaZ37W80UU3QUGlKkY=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace libvscode-diff/CMakeLists.txt \
      --replace-fail 'COMMAND brew --prefix libomp' 'COMMAND echo ${llvmPackages.openmp}'
  '';

  nativeBuildInputs = [ cmake ] ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.openmp ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  # Cleanup
  preInstall = ''
    rm -rf build
  '';

  # The plugin detects Nix and tries to download libgomp at runtime.
  # Symlinking it into the plugin directory fixes error message.
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -s ${stdenv.cc.cc.lib}/lib/libgomp.so.1 $out/libgomp.so.1
  '';

  dependencies = [ vimPlugins.nui-nvim ];
  dontUseCmakeConfigure = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VSCode-style side-by-side diff rendering with two-tier highlighting (line + character level)";
    homepage = "https://github.com/esmuellert/codediff.nvim/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
