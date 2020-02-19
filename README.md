# scann3r
Bash infused automatic recon helper. Inspired by Lee Baird's DISCOVER tool.

About
	I started writing scann3r as an example automated tool for my Linux and Ethical hacking class. It uses the simple concepts of hosts discovery and hosts ip generation. I even threw in some nmap examples. The idea is to create a simple GUI that allows a user to quickly run this script to get live hosts on a network and then run Nmap for port and service discovery. I later started my OSCP journey and discovered AutoRecon through r/oscp. This tool turned out to be an invaluable asset to my tool box. I incorporated AutoRecon from github.com/Tib3rius/AutoRecon, which I highly recommend.

Dependencies
 - On any flavor of Linux (Kali recommended as most tools area lready available)
 - Bash
 - Nmap
 - AutoRecon
 - ar_fancy_html.py (this script creates a easy to navigate HTML page with the list of AutoRecon'd hosts)
