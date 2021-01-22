{ stdenv, fetchurl }:

# stdenv.mkDerivation {
#   name = "brcmfmac43340";

#   src = fetchurl {
#     url = "https://android.googlesource.com/platform/hardware/broadcom/wlan/+archive/master/bcmdhd/firmware/bcm43341.tar.gz";
#     sha256 = "0cd25rrmc0b74pxhhgv1jgjwfk6214pz1s7lffplsc4s354h1wd9";
#   };

#   sourceRoot = ".";

#   installPhase = ''
#     mkdir -p $out/lib/firmware/brcm

#     cp fw_bcm43341.bin $out/lib/firmware/brcm/brcmfmac43340-sdio.bin
#     cp fw_bcm43341.bin $out/lib/firmware/brcm/brcmfmac43341-sdio.bin
#     cp ${./brcm.txt} $out/lib/firmware/brcm/brcmfmac43340-sdio.txt
#     cp ${./brcm.txt} $out/lib/firmware/brcm/brcmfmac43341-sdio.txt
#   '';
# }
let
  bin = fetchurl {
    url = "https://github.com/OpenELEC/wlan-firmware/blob/master/firmware/brcm/brcmfmac43340-sdio.bin";
    sha256 = "1k1xjbkls6hjdwlwcgrvjcvv0vhgdirqvxlyzpssq205qygqskqf";
  };
in
stdenv.mkDerivation {
  name = "brcmfmac43340";
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/lib/firmware/brcm
    cp ${bin} $out/lib/firmware/brcm/brcmfmac43340-sdio.bin
    cp ${./brcm.txt} $out/lib/firmware/brcm/brcmfmac43340-sdio.txt
  '';
}
