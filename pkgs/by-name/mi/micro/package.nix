{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  installShellFiles,
  versionCheckHook,
  withWlClipboard ? null,
  withWlclip ? null,
  # Deprecated options
  # Remove them as soon as possible
  withXclip ? null,
}:

let
  self = buildGoModule {
    pname = "micro";
    version = "2.0.15";

    src = fetchFromGitHub {
      owner = "micro-editor";
      repo = "micro";
      rev = "v${self.version}";
      hash = "sha256-4C6TtMU6PIYX7lO+o4GRVnIsKnYJxjAqPdoOyAwi7Gc=";
    };

    outputs = [
      "out"
      "man"
    ];

    strictDeps = true;
    nativeBuildInputs = [ installShellFiles ];
    vendorHash = "sha256-bkPd6zB9e4q6N20wbKS8n8zGGITOoScajdPYv7Race0=";

    preBuild = ''
      GOOS= GOARCH= go generate ./runtime
    '';

    postInstall = ''
      installManPage assets/packaging/micro.1
      install -Dm444 assets/packaging/micro.desktop $out/share/applications/micro.desktop
      install -Dm644 assets/micro-logo-mark.svg $out/share/icons/hicolor/scalable/apps/micro.svg
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];

    ldflags =
      let
        t = "github.com/zyedidia/micro/v2/internal";
        # TODO: switch to this once the source code uses it, passthru.tests.version checks for this
        # t = "github.com/micro-editor/micro/v2/internal";
      in
      [
        "-s"
        "-w"
        "-X ${t}/util.Version=${self.version}"
        "-X ${t}/util.CommitHash=${self.src.rev}"
      ];

    proxyVendor = true;
    subPackages = [ "cmd/micro" ];

    passthru = {
      tests = lib.packagesFromDirectoryRecursive {
        inherit callPackage;
        directory = ./tests;
      };

      wrapper = callPackage ./wrapper.nix { micro = self; };
    };

    meta = {
      description = "Modern and intuitive terminal-based text editor";

      longDescription = ''
        micro is a terminal-based text editor that aims to be easy to use and
        intuitive, while also taking advantage of the capabilities of modern
        terminals.

        As its name indicates, micro aims to be somewhat of a successor to the
        nano editor by being easy to install and use. It strives to be enjoyable
        as a full-time editor for people who prefer to work in a terminal, or
        those who regularly edit files over SSH.
      '';

      homepage = "https://micro-editor.github.io";
      changelog = "https://github.com/micro-editor/micro/releases/";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        pbsds
      ];

      mainProgram = "micro";
    };
  };
in
lib.warnIf (withXclip != null || withWlClipboard != null || withWlclip != null) ''
  The options `withXclip`, `withWlClipboard`, `withWlclip` were removed. If
  you are seeking for clipboard support, please consider the following
  packages:
  - `micro-with-wl-clipboard`
  - `micro-with-xclip`
  - `micro-full`
'' self
