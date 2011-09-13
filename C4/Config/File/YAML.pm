package C4::Config::File::YAML;
# Copyright 2011 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use YAML;

sub _fileload{
    my ($filename)=shift;
    return YAML::LoadFile($filename);
}

sub _dirload{
    my $dirname=shift;
    my $result;
    opendir D, $dirname;
    for my $name (readdir(D)){
        next if $name=~/^\./;
        if (-d $name){
            $result->{$name}=_dirload($dirname."/".$name);
        }
        if ((-e $dirname."/".$name) and ($name=~/\.ya?ml/) ){
            $result=($result
                    ? [%$result,%{_fileload($dirname."/".$name)}]
                    : _fileload($dirname."/".$name));
        }
    }
    return $result;
}


sub new{
    my $config;
    my $self=shift;
    my $name=shift;
    if (-e $name){
        $config=_fileload($name);
    }
    if (-d $name){
        $config->{$name}=_dirload($name);
    }
    return $config;
}
1;

