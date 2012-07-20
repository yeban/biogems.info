#! /usr/bin/env ruby
#
# Create a database (YAML) of (Cloud)BioLinux packages
#

$: << "lib"
require 'biogems/biolinux/biolinux'
require 'biogems/debian/debian'

is_testing = ARGV[0] == '--test'

BIOLINUX_DEBIAN_MANIFEST = 
  if is_testing
    File.read('test/data/biolinux/debian-packages.yaml')
  else
    `curl -s https://raw.github.com/chapmanb/cloudbiolinux/master/manifest/debian-packages.yaml` 
end

@biolinux = BiolinuxManifest.new(BIOLINUX_DEBIAN_MANIFEST)

# Debian Tasks
tasknames = 'bio bio-dev bio-ngs bio-phylogeny cloud data epi his oncology'
biomed = []

if is_testing
  biomed << Debian::BlendTask.new(File.read('test/data/debian/bio-task.txt'))
else
  tasknames.split.each do |taskname|
    $stderr.print "Fetching ", taskname,"\n"
    biomed << Debian::BlendTask.new(`curl -s http://anonscm.debian.org/viewvc/blends/projects/med/trunk/debian-med/tasks/#{taskname}?view=co`)
  end
end
pkgs = []
@biolinux.each do | name, pkg |
  biomed.each do |bm|
    if bm[name] == true
      pkgs << pkg
    end
  end
end

print pkgs.to_yaml

$stderr.print "\n",pkgs.size," packages found!\n"
