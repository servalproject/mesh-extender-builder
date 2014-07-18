Serval Mesh Extender Builder
============================

This repository contains the mechanisms required to create and install the software
images on TP-Link MR3020-based Serval Mesh Extenders.

Two-stage process
-----------------

The build stage consists of generating the OpenWrt firmware image and the
complementary software that is required to be installed on a USB stick inserted
into the USB port of the unit.  The build stage only needs to be performed once.

Once the firmware and USB software image have been built, these then need to be
installed on MR3020s and USB memory sticks, respectively.  This can be done
many times to install many units quite quickly, taking 2 - 5 minutes per
Mesh Extender with a little practice.  It is possible to parallelise this,
installing the MR3020 image on one computer, and using another computer to generate
one or more USB memory sticks simultaneously.

You will need a computer running linux on an x86 or amd64 processor (a laptop will
do) to perform these steps,
because we need to create Linux ext4 file systems.  It would be possible to port
the process to other operating systems, and we invite the community to contribute
in this regard. In particular, it would be useful to have options for Windows and
OSX.

The necessary steps are described below.

Build Stage
===========

1. Building MR3020 Firmware image
---------------------------------

Run the make_image script.

This will download the ~400MB OpenWrt Image Builder, and create the firmware
image.

2. Build USB software image
---------------------------

You must have completed the previous step before you can move onto this one, because
it uses the contents of the OpenWrt Image Builder that it downloads.

Run the  gather-image-files script.

This will create the staging directory which contains the files that will end up on
the /serval partition of the USB memory stick that each Mesh Extender requires to
operate.

Installation Stage
==================

The following process can be repeated on as many units as you wish, without having to
repeat the steps of the build stage.

1. Flash MR3020 with Mesh Extender firmware image
-------------------------------------------------

First, power-up your MR3020.  If you wish to produce many Mesh Extenders in a short
period of time, you may wish to have one powering up while you flash another, as these
little treasures can take a couple of minutes to boot.

Second, connect it to your computer via ethernet cable.  Wireless installation is probably
possible, and we welcome feedback on that, but for now we only officially support cabled
installation.

There are two alternatives at this point which you must select from. If you don't know
which one to use, try one, and if it doesn't work, then try the other -- you can't break
any thing.

If your MR3020 still has the factory image installed, then run the  flash-virgin-mr3020
script.

If your MR3020 already has some OpenWrt image installed, then run the reflash-mesh-extender
script.

Both of these scripts attempt to work out the IP address of the MR3020.  You can override
this by providing an IP address as a command line argument to the scripts.

If you already have OpenWrt on your MR3020, and reflash-mesh-extender fails, try rebooting
your MR3020 into failsafe mode and or running firstboot on it and removing the root password
so that it reflash-mesh-extender can easily log in via telnet.

Whichever path you follow, it should install the new firmware and reboot the MR3020.  Wait
until the connection to the MR3020 is dropped before removing power from the MR3020 so that
you don't brick it by cutting power while it is reflashing itself.

2. Preparing a USB memory stick
-------------------------------

The first step is to know the device node of the USB memory stick, e.g., sdb.  Take great care
with this, because if you get it wrong, you might be asking the scripts to delete repartition
and/or reformat your entire hard drive!  The scripts do take some precautions, for example by
refusing to proceed if it thinks the device is already mounted somewhere, but it can't be
failsafe.

If all that sounds like gobbledy-gook, then it is probably best to find someone to help you,
and you shouldn't proceed on your own.

The procedure boils down to:

1.  Insert a USB memory stick and work out the device node for it.
2.  Run partition-memory-stick.sh AS ROOT with the device node as command line argument.  Clearly this step is DANGEROUS if you give it the wrong device.
3.  REMOVE AND REINSERT the memory stick.  This makes sure that the Linux kernel reloads the partition table.
4.  Run populate-memory-stick AS ROOT, again with the device node as the command line argument. This step is also DANGEROUS if you give it the wrong device, as it will reformat partitions on the device it is given.
5.  All done!

Powering up and testing a new Mesh Extender
===========================================

Once you have prepared an MR3020 and a USB memory stick, plug them together and
power it up.  Once it powers up, it should offer public.servalproject.org as a
Wi-Fi network with the standard Mesh Extender captive portal.

Notes and Limitations
=====================

This process is still being finalised, and a few things are currently missing.

The RFD900 radio (if present) does not (yet) get reflashed on first boot.  We
intend to fix this in the next couple of days.

The created image does not support full over-the-mesh/air auto-update. We
intend to fix this, too, in the next week or so.

The created image does not include the latest Serval Mesh Android APK or source
code.  This, too, will get fixed Real Soon Now.

