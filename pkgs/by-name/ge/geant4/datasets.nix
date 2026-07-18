{
  lib,
  stdenv,
  fetchurl,
  geant4,
}:

let
  mkDataset =
    {
      envvar,
      pname,
      sha256,
      version,
    }:
    stdenv.mkDerivation {
      inherit pname version;
      inherit envvar;

      src = fetchurl {
        inherit sha256;
        url = "https://cern.ch/geant4-data/datasets/${pname}.${version}.tar.gz";
      };

      installPhase = ''
        mkdir -p $datadir
        mv ./* $datadir
      '';

      datadir = "${placeholder "out"}/share/Geant4-${geant4.version}/data/${pname}${version}";
      dontBuild = true;
      dontConfigure = true;
      geant_version = geant4.version;
      preferLocalBuild = true;
      setupHook = ./datasets-hook.sh;

      meta = {
        description = "Data files for the Geant4 toolkit";
        homepage = "https://geant4.web.cern.ch/support/download";
        license = lib.licenses.g4sl;
        platforms = lib.platforms.all;
      };
    };
in
builtins.listToAttrs (
  map
    (a: {
      name = a.pname;
      value = mkDataset a;
    })
    [
      {
        pname = "G4NDL";
        version = "4.7.1";
        envvar = "NEUTRONHP";
        sha256 = "sha256-06yuSGIhGNJXneJKVNUz+yQWvw2p3SiPFyTfFIWkbHw=";
      }

      {
        pname = "G4EMLOW";
        version = "8.8";
        envvar = "LE";
        sha256 = "sha256-tgz9YxdvXRYQfiols1sjUVUDLRc110lnDKUP7eEmJM8=";
      }

      {
        pname = "G4PhotonEvaporation";
        version = "6.1.2";
        envvar = "LEVELGAMMA";
        sha256 = "sha256-AhScCrkdiO4k54UyVYd345oGi5/N0ZkTYQH/WOY150I=";
      }

      {
        pname = "G4RadioactiveDecay";
        version = "6.1.2";
        envvar = "RADIOACTIVE";
        sha256 = "sha256-pA1+Prxk01VVxKSdD/HglFzWBdhDVNBTEhKTkUyuoTo=";
      }

      {
        pname = "G4SAIDDATA";
        version = "2.0";
        envvar = "SAIDXS";
        sha256 = "sha256-HSao55uqceRNV1m59Vpn6Lft4xdRMWqekDfYAJDHLpE=";
      }

      {
        pname = "G4PARTICLEXS";
        version = "4.2";
        envvar = "PARTICLEXS";
        sha256 = "sha256-xSu/hqqlibeKuoCxarCt8QQeowDeU5WGW5f87m61WFE=";
      }

      {
        pname = "G4ABLA";
        version = "3.3";
        envvar = "ABLA";
        sha256 = "sha256-HgQbMlLunO+IbWJPdT5pMwOqMtfl7zu6h7NPNtkuorE=";
      }

      {
        pname = "G4INCL";
        version = "1.3";
        envvar = "INCL";
        sha256 = "sha256-5LPb5SrO9TU2RU4iRDCRIShDghvSNiju2EbSmVmfO/k=";
      }

      {
        pname = "G4PII";
        version = "1.3";
        envvar = "PII";
        sha256 = "sha256-YiWtkCZ19DgcmMa6JfxaBs6HVJqpeWNNPQNJHWYW6SY=";
      }

      {
        pname = "G4ENSDFSTATE";
        version = "3.0";
        envvar = "ENSDFSTATE";
        sha256 = "sha256-S9w71Asx1DSFv0+H8FVwXlQKZVfWTthcaJxZyaTrp9Y=";
      }

      {
        pname = "G4RealSurface";
        version = "2.2";
        envvar = "REALSURFACE";
        sha256 = "sha256-mVTe4AEvUzEmf3g2kOkS5y21v1Lqm6vs0S6iIoIXaCA=";
      }

      {
        pname = "G4TENDL";
        version = "1.4";
        envvar = "PARTICLEHP";
        sha256 = "sha256-S3J0AgzItO1Wm4ku8YwuCI7c22tm850lWFzO4l2XIeA=";
      }

      {
        pname = "G4CHANNELING";
        version = "2.0";
        envvar = "CHANNELING";
        sha256 = "sha256-ZiFZKIZE4Ht51/4JHvvrulK1lUaz3G9dKFuXatEvLQY=";
      }

      {
        pname = "G4NUDEXLIB";
        version = "1.0";
        envvar = "NUDEXLIB";
        sha256 = "sha256-ysfWXpxa+O26KyZn1YIuFqr5kGXJX4Bedt5MyGOV9BU=";
      }

      {
        pname = "G4URRPT";
        version = "1.1";
        envvar = "URRPT";
        sha256 = "sha256-ajQy24C8CIruGcUEucASSRMAXWNX6hSHBFFACrINnBE=";
      }
    ]
)
