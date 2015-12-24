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

Controlling configuration of Mesh Extender using files on FAT partition
=======================================================================

Primarily to ease development, Mesh Extender images built using this tool
a number of special files on the FAT partition (mounted as /dos).  This
allows someone to take the USB memory stick out of a Mesh Extender, insert
it into almost any computer, and modify the behaviour of the Mesh Extender
by creating a few simple files using a text editor.

The following is a (probably incomplete) list of the special files that are
supported:

1. noroot
---------

This gets created automatically after each boot. If it is missing during boot,
the Mesh Extender will allow root login using the password root. Delete this
file to allow root login via SSH for exactly one boot cycle.

2. yesroot
----------

If you REALLY want root access after every reboot, instead of just for one
boot, create a file called yesroot, and put the root password that you would
like to use in there.

If this file is present, noroot will be ignored.

3. hipower.en
-------------

If this file is present, AND the switch on the MR3020 is in the centre position,
lbard will attempt to operate any connected RFD900 UHF radio at 250mW instead of
3mW.  YOU CURRENTLY REQUIRE A SPECIAL SPECTRUM LICENSE TO DO THIS!  (This will
hopefully change with the RFD900X radios that use wider channels, and so meet
the FCC and ACMA class licenses for the ISM 915MHz band.)

4. otabid.txt
-------------

If this file is present, and contains a valid Rhizome Bundle ID (BID), that
bundle will be assumed to contain an authorised over-the-air (OTA) update, that
will be used to update the key Serval daemons on the Mesh Extender.  Take a
look in over-the-air-update in this repository to see how to build OTA updates.

5. monitor.sid
--------------

If this file is present, a MeshMS message will be sent to the SID contained in
the file whenever an OTA update is applied.  This helps you know when your
Mesh Extenders are running the version of binaries you expect. The Message will
contain the GIT commit of the mesh-extender-builder repository that was used
to create the OTA update.

6. nomesh
---------

If this file is present, the ad-hoc wifi interface will be disabled. Your Mesh
Extender will communicate with other Mesh Extenders only via RFD900 UHF packet
radio while in this mode.  Phones will still be able to connect as wifi clients
to the Mesh Extender.

7. apssid
---------

If this file is present, the wifi access point will use the contents of the file
as the SSID instead of public.servalproject.org.  This is handy if you have multiple
Mesh Extenders together in a room, and want to be able to connect to specific ones
via wifi.

8. nouhf
--------

Completely disable the UHF radio by not running the LBARD daemon. Handy if taking
your Mesh Extender to another country where the ISM 915MHz band is not permitted.

9. helpdesk.sid
---------------

Contains the SID to which messages requesting help should be sent. This is used to
enable a web form on the main page of the mesh extender.


999. Forbidden filenames

NEVER create files on the FAT partition with the following names:
	MeshExtender
	ota-update
        justinbieber

Providing NTP time for a Mesh Extender
======================================

Mesh Extenders look for an NTP server on 192.168.2.54 or the usual openwrt NTP
servers via their ethernet connection.
They probably won't share NTP information via adhoc wifi, because of how the busybox
ntp daemon works. 

We are in the process of adding a mechanism to allow Mesh Extenders to approximately
synchronise their clocks via the RFD900 UHF packet radios for when this is not possible.
This is just to give hopefully meaningful timestamps for logs, and should not be
otherwise considered reliable. It will probably only be accurate to +/- a few seconds.


Notes and Limitations
=====================

This process is still being finalised, and a few things are currently missing.

There are sure to be bugs.
