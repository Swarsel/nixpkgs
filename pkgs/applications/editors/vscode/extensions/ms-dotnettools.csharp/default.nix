{
  lib,
  stdenv,
  autoPatchelfHook,
  coreutils,
  fetchzip,
  glibc,
  icu,
  jq,
  libkrb5,
  libz,
  openssl,
  patchelf,
  vscode-utils,
}:
let
  extInfo = (
    {
      aarch64-darwin = {
        arch = "darwin-arm64";
        hash = "sha256-KCIkjBmYZPiuFmQ3/aDycARYIHPyDTmMkoGcuG5DQX8=";
      };

      aarch64-linux = {
        arch = "linux-arm64";
        hash = "sha256-EV3745OXbwrRmc8P5e13DZbomyJGcYQUF07WflRWU1Q=";
      };

      x86_64-linux = {
        arch = "linux-x64";
        hash = "sha256-FTS8cK9ovmxGLnywOGTIP7oUOHZ4RLE5t7lfhltdmIc=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
  );

  # Get url from runtimeDependencies in package.json
  # TODO: Automate fetching runtimeDependencies from package.json
  #       ideally should be done at the vscode-extensions level for
  #       everyone to reuse.
  roslyn-copilot = fetchzip {
    hash = "sha256-Eh1XaF9eCN5saTrIf4NeZZKDeiEvrTo0m+vOiM5QZoI=";

    postFetch = ''
      touch install.Lock
    '';

    url = "https://roslyn.blob.core.windows.net/releases/Microsoft.VisualStudio.Copilot.Roslyn.LanguageServer-18.3.72-alpha.zip";
  };
in
vscode-utils.buildVscodeMarketplaceExtension {
  postPatch = ''
    substituteInPlace dist/extension.js \
      --replace-fail 'uname -m' '${lib.getExe' coreutils "uname"} -m'
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    jq
    patchelf
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.getLib glibc) # libgcc_s.so.1
    (lib.getLib icu) # libicui18n.so libicuuc.so
    (lib.getLib libkrb5) # libgssapi_krb5.so
    (lib.getLib libz) # libz.so.1
    (lib.getLib openssl) # libopenssl.so.3
    (lib.getLib stdenv.cc.cc) # libstdc++.so.6
  ];

  postInstall = ''
    ln -s ${roslyn-copilot} "$out"/share/vscode/extensions/ms-dotnettools.csharp/.roslynCopilot
  '';

  preFixup = ''
    (
      set -euo pipefail
      shopt -s globstar
      shopt -s dotglob

      # Fix all binaries.
      for file in "$out"/**/*; do
        if [[ ! -f "$file" || "$file" == *.so || "$file" == *.a || "$file" == *.dylib ]] ||
            (! isELF "$file" && ! isMachO "$file"); then
            continue
        fi

        echo Making "$file" executable...
        chmod +x "$file"

        ${lib.optionalString stdenv.hostPlatform.isLinux ''
          # Add .NET deps if it is an apphost.
          if grep 'You must install .NET to run this application.' "$file" > /dev/null; then
            echo "Adding .NET needed libraries to: $file"
            patchelf \
              --add-needed libicui18n.so \
              --add-needed libicuuc.so \
              --add-needed libgssapi_krb5.so \
              --add-needed libssl.so \
              "$file"
          fi
        ''}
      done

      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        # Add the ICU libraries as needed to the globalization DLLs.
        for file in "$out"/**/{libcoreclr.so,*System.Globalization.Native.so}; do
          echo "Adding ICU libraries to: $file"
          patchelf \
            --add-needed libicui18n.so \
            --add-needed libicuuc.so \
            "$file"
        done

        # Add the Kerberos libraries as needed to the native security DLL.
        for file in "$out"/**/*System.Net.Security.Native.so; do
          echo "Adding Kerberos libraries to: $file"
          patchelf \
            --add-needed libgssapi_krb5.so \
            "$file"
        done

        # Add the OpenSSL libraries as needed to the OpenSSL native security DLL.
        for file in "$out"/**/*System.Security.Cryptography.Native.OpenSsl.so; do
          echo "Adding OpenSSL libraries to: $file"
          patchelf \
            --add-needed libssl.so \
            "$file"
        done

        # Add the needed binaries to the apphost binaries.
        for file in $(jq -r '.runtimeDependencies | map(select(.binaries != null) | .installPath + "/" + .binaries[]) | sort | unique | map(sub("/\\./"; "/")) | .[]' < "$out"/share/vscode/extensions/ms-dotnettools.csharp/package.json); do
          [ -f "$out"/share/vscode/extensions/ms-dotnettools.csharp/"$file" ] || continue

          echo "Adding .NET needed libraries to: $out/share/vscode/extensions/ms-dotnettools.csharp/$file"
          patchelf \
            --add-needed libicui18n.so \
            --add-needed libicuuc.so \
            --add-needed libgssapi_krb5.so \
            --add-needed libssl.so \
            "$out"/share/vscode/extensions/ms-dotnettools.csharp/"$file"
        done
      ''}
    )
  '';

  mktplcRef = {
    inherit (extInfo) hash arch;
    version = "2.140.8";
    name = "csharp";
    publisher = "ms-dotnettools";
  };

  meta = {
    description = "Official C# support for Visual Studio Code";
    homepage = "https://github.com/dotnet/vscode-csharp";
    license = lib.licenses.unfree;
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
