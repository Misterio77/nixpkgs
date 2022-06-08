{ pkgs, lib, stdenv, fetchFromGitHub, fetchzip, darktable, rawtherapee, ffmpeg, libheif, exiftool, nixosTests }:

let
  version = "220302-0059f429";
  pname = "photoprism";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-hEA2E5ty9j9BH7DviYh5meao0ot0alPgMoJcplJDRc4=";
  };

  libtensorflow = pkgs.callPackage ./libtensorflow.nix { };
  backend = pkgs.callPackage ./backend.nix { inherit libtensorflow src version; };
  frontend = pkgs.callPackage ./frontend.nix { inherit src version; };

  fetchModel = { name, sha256 }:
    fetchzip {
      inherit sha256;
      url = "https://dl.photoprism.org/tensorflow/${name}.zip";
      stripRoot = false;
    };

  facenet = fetchModel {
    name = "facenet";
    sha256 = "sha256-aS5kkNhxOLSLTH/ipxg7NAa1w9X8iiG78jmloR1hpRo=";
  };

  nasnet = fetchModel {
    name = "nasnet";
    sha256 = "sha256-bF25jPmZLyeSWy/CGXZE/VE2UupEG2q9Jmr0+1rUYWE=";
  };

  nsfw = fetchModel {
    name = "nsfw";
    sha256 = "sha256-zy/HcmgaHOY7FfJUY6I/yjjsMPHR2Ote9ppwqemBlfg=";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  buildInputs = [
    darktable
    rawtherapee
    ffmpeg
    libheif
    exiftool
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,assets}
    # install backend
    ln -s ${backend}/bin/photoprism $out/bin/photoprism
    # install frontend
    ln -r ${frontend}/assets $out/
    # install tensorflow models
    ln -r ${nasnet}/nasnet $out/assets
    ln -r ${nsfw}/nsfw $out/assets
    ln -r ${facenet}/facenet $out/assets

    runHook postInstall
  '';

  passthru.tests.photoprism = nixosTests.photoprism;

  meta = with lib; {
    homepage = "https://photoprism.app";
    description = "Personal Photo Management powered by Go and Google TensorFlow";
    inherit (libtensorflow.meta) platforms;
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ misterio77 ];
  };
}
