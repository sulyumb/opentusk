#!/usr/bin/perl

# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script copies URIs from the Competency table and inserts them to the new feature_link table. 
# Removes URIs from the Competency table at the end.
# IMPORTANT : It is highly recommended that you create a backup of your competency table
# before running this script.

use strict;
use warnings;


use TUSK::Enum::Data;

use TUSK::Competency::Competency;
use TUSK::Feature::Link;

my %national_competency_URIs;

main();

sub main {
    getURIsFromCompetencyTable();
    setURIsToFeatureLinkTable();
}

sub getURIsFromCompetencyTable {
    my $competency_level_enum_id = TUSK::Enum::Data->lookupReturnOne("namespace = \"competency.level_id\" AND short_name = \"national\"")->getPrimaryKeyID;
    my $national_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_level_enum_id");
    foreach my $national_competency (@{$national_competencies}) {
	$national_competency_URIs{$national_competency->getPrimaryKeyID} = $national_competency->getUri;
    }
}

sub setURIsToFeatureLinkTable {
    my $feature_link_enum_id = TUSK::Enum::Data->lookupReturnOne("namespace = \"feature_link.feature_type\" AND short_name = \"competency\"")->getPrimaryKeyID;
    foreach my $national_competency_uri_id (keys %national_competency_URIs) {
	my $featureLinkRelation = TUSK::Feature::Link->new();
	if ($national_competency_URIs{$national_competency_uri_id}){
	    $featureLinkRelation->setFieldValues({
		feature_type_enum_id => $feature_link_enum_id,
		feature_id => $national_competency_uri_id,
		url => $national_competency_URIs{$national_competency_uri_id},
	    });
	    $featureLinkRelation->save({user => "script"});
	}
    }
}
