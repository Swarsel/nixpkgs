{
  lib,
  stdenv,
  coreutils,
  curl,
  fetchzip,
  gnugrep,
  htmlq,
  nix-update,
  # update script
  writeScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fasmg";
  version = "l7xm";

  src = fetchzip {
    url = "https://flatassembler.net/fasmg.${finalAttrs.version}.zip";
    sha256 = "sha256-m/mLZLluvoxr0VsNVcBnHvv1LlagafkX6fwZSovtO9s=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "doc"
  ];

  buildPhase =
    let
      inherit (stdenv.hostPlatform) system;

      path =
        {
          x86-darwin = {
            asm = "source/macos/fasmg.asm";
            bin = "source/macos/fasmg";
          };

          x86-linux = {
            asm = "source/linux/fasmg.asm";
            bin = "fasmg";
          };

          x86_64-linux = {
            asm = "source/linux/x64/fasmg.asm";
            bin = "fasmg.x64";
          };
        }
        .${system} or (throw "Unsupported system: ${system}");

    in
    ''
      chmod +x ${path.bin}
      ./${path.bin} ${path.asm} fasmg
    '';

  installPhase = ''
    install -Dm755 fasmg $out/bin/fasmg

    mkdir -p $doc/share/doc/fasmg
    cp docs/*.txt $doc/share/doc/fasmg
  '';

  passthru.updateScript = writeScript "update-fasmg.sh" ''
    export PATH="${
      lib.makeBinPath [
        coreutils
        curl
        gnugrep
        htmlq
        nix-update
      ]
    }:$PATH"
    version=$(
      curl 'https://flatassembler.net/download.php' \
        | htmlq .links a.boldlink  -a href \
        | grep -E '^fasmg\..*\.zip$' \
        | head -n1 \
        | cut -d. -f2
    )
    nix-update fasmg --version "$version"
  '';

  meta = {
    description = "x86(-64) macro assembler to binary, MZ, PE, COFF, and ELF";
    homepage = "https://flatassembler.net";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.iamanaws ];
    platforms = with lib.platforms; lib.intersectLists (linux ++ darwin) x86;
    mainProgram = "fasmg";
  };
})
