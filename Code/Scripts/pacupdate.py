# -*- coding: utf-8 -*-

import re
import subprocess
import webbrowser
import textwrap
from urllib import urlopen
from contextlib import closing
from time import strptime, sleep
from os import getenv, path, mkdir
from calendar import timegm

arch_home = "https://www.archlinux.org/"
arch_feed = "https://www.archlinux.org/feeds/news/"

home_dir = getenv("HOME")
downloads_dir = home_dir + "/Downloads"
aur_dir = downloads_dir + "/AUR"
vcs_dir = aur_dir + "/VCS"

supported_vcs = ["git"]

def print_bold(text, optional_text=""):
    print "\033[1m" + text + "\033[0m" + optional_text

def get_feed_time():
    search_needle = re.compile(r"<lastBuildDate>")
    replace_needle = re.compile(r"^.+?<lastBuildDate>(.+?) \+.+",
                                flags=re.DOTALL)
    strptime_pattern = "%a, %d %b %Y %X"
    
    with closing(urlopen(arch_feed)) as rss_source:
        for rss_source_line in rss_source:
            if re.search(search_needle, rss_source_line):
                curr_feed = re.sub(replace_needle, "\g<1>", rss_source_line)
                curr_feed_t = strptime(curr_feed, strptime_pattern)
                return timegm(curr_feed_t)
                
def aur_install(candidate, directory):
    subprocess.call(["cower", "-df", candidate, "-t", directory])
    package_dir = directory + "/" + candidate
    subprocess.call(["makepkg", "-sri"], cwd=package_dir)


#create missing folders
for directory in [downloads_dir, aur_dir, vcs_dir]:
    if not path.exists(directory):
        mkdir(directory)

#open config file and store content in $config
config_file_name =  home_dir + "/.config/pacupdate.conf"

if not path.isfile(config_file_name):
    webbrowser.open_new_tab(arch_home)        
    with open(config_file_name, "w") as config_file:
        config_file.write(str(get_feed_time()))
        output = """\
        This is the first time pacupdate is run, so there is no way to know
        whether or not there are any updates in the ArchLinux feed. A config
        file has been created that will serve this purpose in the future. The
        browser has been opened and pointed to the Arch news page so you can
        check if you"re good to go."""
        print textwrap.fill(textwrap.dedent(output), 80)
        quit()

else:
    with open(config_file_name, "r") as config_file:
        config = config_file.read().splitlines()


print "Neues im Arch-Newsfeed?"
last_feed_t = config[0]
curr_feed_t = str(get_feed_time())

if last_feed_t == curr_feed_t:
    print_bold("\tNein.")
else:
    print_bold("\tJa.")
    sleep(1)
    webbrowser.open_new_tab(arch_home)
    config[0] = curr_feed_t + "\n"
    with open(config_file_name, "w") as config_file:
        config_file.writelines(config)
    quit()
    

print "Neues in den Repositorien?"
subprocess.call(["sudo", "pacman", "-Sy"], stdout=subprocess.PIPE)
repo_checkupdates = subprocess.Popen(["sudo", "pacman", "-Qu"], stdout=subprocess.PIPE)
repo_update_list = repo_checkupdates.communicate()[0].splitlines()
repo_updates = len(repo_update_list)
if repo_updates > 0:
    print_bold("\tJa, ", str(repo_updates) + " neue Updates.")
    repo_update_switch = True
else:
    print_bold("\tNein.")


print "Neues im AUR?"
aur_checkupdates = subprocess.Popen(["cower", "-uq", "--timeout", "0"], 
stdout=subprocess.PIPE)
aur_update_list = aur_checkupdates.communicate()[0].splitlines()
aur_updates = len(aur_update_list)
if aur_updates > 0:
    print_bold("\tJa, ", str(aur_updates) + " neue Updates.")
    aur_update_switch = True
else:
    print_bold("\tNein.")
    
all_updates = repo_updates + aur_updates

if all_updates > 0:
    response = raw_input("\033[1mMit allen %s Updates fortfahren? [J/n] \033[0m" 
                         % all_updates)
else:
    print_bold("Keine Updates verfügbar.")
    quit()

if (response.lower() == "j") or (response == ""):
    if repo_updates > 0:
        subprocess.call(["sudo", "pacman", "-Syu"])
        
    if aur_updates > 0:
        trail_needle = re.compile(r"^.+?-([^-]+)$")
        for candidate in aur_update_list:
            trail = re.sub(trail_needle, r"\1", candidate)
            if trail in supported_vcs:
                aur_install(candidate, vcs_dir)
            else:
                aur_install(candidate, aur_dir)