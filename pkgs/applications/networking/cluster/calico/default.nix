{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

builtins.mapAttrs
  (
    pname:
    {
      subPackages,
      doCheck ? true,
      mainProgram ? pname,
    }:
    buildGoModule rec {
      inherit pname;
      inherit doCheck subPackages;
      version = "3.31.6";

      src = fetchFromGitHub {
        owner = "projectcalico";
        repo = "calico";
        rev = "v${version}";
        hash = "sha256-lME1x04iFaNg+dilS66dGuFmw3IEJQmyPcnDvGTzk/8=";
      };

      vendorHash = "sha256-8CvnDaoEkb/yMMgGBG03RFrdHdc5Anbv9t1TnOYHA9A=";

      ldflags = [
        "-s"
        "-w"
      ];

      meta = {
        inherit mainProgram;
        description = "Cloud native networking and network security";
        homepage = "https://projectcalico.docs.tigera.io";
        changelog = "https://github.com/projectcalico/calico/releases/tag/v${version}";
        license = lib.licenses.asl20;
        maintainers = [ ];
        platforms = lib.platforms.linux;
      };
    }
  )
  {
    calico-apiserver = {
      mainProgram = "apiserver";

      subPackages = [
        "apiserver/cmd/..."
      ];
    };

    calico-app-policy = {
      # integration tests require network
      doCheck = false;
      mainProgram = "dikastes";

      subPackages = [
        "app-policy/cmd/..."
      ];
    };

    calico-cni-plugin = {
      mainProgram = "calico";

      subPackages = [
        "cni-plugin/cmd/..."
      ];
    };

    calico-kube-controllers = {
      # integration tests require network and docker
      doCheck = false;
      mainProgram = "kube-controllers";

      subPackages = [
        "kube-controllers/cmd/..."
      ];
    };

    calico-pod2daemon = {
      mainProgram = "flexvol";

      subPackages = [
        "pod2daemon/csidriver"
        "pod2daemon/flexvol"
        "pod2daemon/nodeagent"
      ];
    };

    calico-typha = {
      subPackages = [
        "typha/cmd/..."
      ];
    };

    calicoctl = {
      subPackages = [
        "calicoctl/calicoctl"
      ];
    };

    confd-calico = {
      mainProgram = "confd";

      subPackages = [
        "confd"
      ];
    };
  }
