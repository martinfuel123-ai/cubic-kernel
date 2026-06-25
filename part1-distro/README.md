# Custom Linux Distribution Report — Part 1

## General Information
* Developer: PATIN COTACACHI RAFAEL ALEXANDRE
* Base OS: Ubuntu 24.04.4 LTS (Noble Numbat)
* Generation Date: 2026-06-25

---

## ISO Download and Verification
* Download Link: https://drive.google.com/file/d/11HdAZHv6kOFGyHo4dCXdqz5MJmD_Q3Ri/view?usp=sharing
* MD5 Checksum: dfa07646a501c0446620ca4fc4ceceaf

### Technical Specifications
* File Name: ubuntu-24.04.4-2026.06.25-desktop-amd64.iso
* Volume ID: Ubuntu 24.04.4 2026.06.25 LTS
* Compression Algorithm: XZ (Optimized for size)
* Final Size: 5.50 GiB (5,901,291,520 bytes)

---

## List of Modifications and Justifications

1. Software Replacement: Celluloid to MPV

* Modification: The default media player Celluloid was removed and replaced by MPV.

* Justification: MPV provides better codec support, lower resource consumption, and greater flexibility for advanced users and system administrators. It was selected as a lightweight and highly customizable open-source alternative.

2. Pre-installation of Development Tools (Neovim)

* Modification: Integrated and pre-installed the advanced text editing environment Neovim.

* Justification: Neovim was incorporated directly into the base ISO along with its basic dependencies. This ensures that the system provides an agile, resource-efficient development editor ready for scripting and Unix administration tasks from the first boot without relying on external repositories.

3. Persistent Customization of the Default User Environment via /etc/skel

* Modification: Configured a persistent custom welcome banner within the command interpreter.

* Justification: The master file '/etc/skel/.bashrc' was edited to add optimized global aliases ('ll') and a personalized welcome message in English. This guarantees that any new user account created automatically inherits these configurations persistently.

4. Default Wallpaper Customization via gschema

* Modification: Configured a custom wallpaper as the default desktop background.

* Justification: The appropriate gschema settings were modified so that the custom wallpaper is applied automatically in new sessions, providing a unique visual identity for the distribution.

---

## Deliverables and Verification
* Demonstration Video: Included as UNIX.mp4 in the project directory https://drive.google.com/file/d/1wx6NPJzGhx_9C5vbWJREChPdSg4Tjf0O/view?usp=drive_link
* Boot Test Status: Successfully verified and tested on Oracle VirtualBox, running perfectly in a clean Live session using the "Try Ubuntu" mode.

## In sumarry
* mpv was installed.

* Neovim was installed (verified with the `nvim` command).

* A default wallpaper was set (gschema).

* A custom terminal welcome message was configured (/etc/skel/.bashrc).

* The customization was made persistent through /etc/skel and gschema modifications.
