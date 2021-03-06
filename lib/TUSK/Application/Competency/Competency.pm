# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::Competency::Competency;

use strict;

use TUSK::Competency::Competency;
use TUSK::Competency::Course;
use TUSK::Competency::Hierarchy;
use TUSK::Competency::Relation;

sub new {
    my ($class, $args) = @_;

    my $self = {
	competency_id => $args->{competency_id},
	title => $args->{title},
	description => $args->{description},
	user_type_id => $args->{user_type_id},
	school_id => $args->{school_id},
	competency_level_enum_id => $args->{competency_level_enum_id},
	version_id => $args->{version_id},
	user => $args->{user},
    };
  
    bless($self, $class);

    $self->{competency} = (defined $self->{competency_id}) ? TUSK::Competency::Competency->lookupReturnOne( "competency_id =". $self->{competency_id}) : TUSK::Competency::Competency->new();

    return $self;
}

#######################################################

=item B<getChildren>

	Return All children for a particular parent_competency, returns an arrayref.
=cut

sub getChildren {
	my ($self, $extra_cond) = @_;

	my $competency_hierarchy = TUSK::Competency::Hierarchy->lookup("parent_competency_id=" . $self->{competency_id});
    
	my @child_competencies;

	foreach my $competency (@{$competency_hierarchy}) {
	    push @child_competencies, $competency->getChildCompetencyID;
	}

	return \@child_competencies;
}


#######################################################

=item B<delete>
    Deletes a given competency object
=cut

sub delete {

    my ($self, $extra_cond) = @_;
    
    my $linked_competencies = 0; # = $self->getLinked; no linking right now but on next update

    #if no linked child competencies, procede with deleting, otherwise not.
    if ( $linked_competencies == 0){
    #if ((scalar @{$linked_competencies}) == 0) { #add check for linking for next update
	#delete competency links related to this competency first
	if (TUSK::Competency::Relation->lookup("competency_id_1 = $self->{competency_id}")){
	    my $parent_links = TUSK::Competency::Relation->lookup("competency_id_1 = $self->{competency_id}");
	    foreach my $parent_link (@{$parent_links}) {
		$parent_link->delete();
	    }
	}
	if (TUSK::Competency::Relation->lookup("competency_id_2 = $self->{competency_id}")){
	    my $child_links = TUSK::Competency::Relation->lookup("competency_id_2 = $self->{competency_id}");
	    foreach my $child_link (@{$child_links}) {
		$child_link->delete();
	    }
	}
	#delete call to database
	my $delete_check = $self->{competency}->delete();

	return $delete_check; 
    } else { 
	return 0;
    }

}

#######################################################


=item B<deleteAssociated>
    Deletes a given competency object with an associated link ( i.e competency_course, competency_class_meeting or competency_content )
=cut

sub deleteAssociated {
    
    my ($self, $extra_cond) = @_;

    my $competency = $self->{competency};

    if (!defined $competency) {
	print "Invalid entry";
	return 0;
    }

    my $competency_level = $competency->getCompetencyLevel;

    if ($competency_level eq "course") {
	my $competency_course = TUSK::Competency::Course->lookupReturnOne("competency_id=". $competency->getPrimaryKeyID);
	$competency_course->delete();
    } elsif ($competency_level eq "class_meet") {
	my $competency_class_meet = TUSK::Competency::ClassMeeting->lookupReturnOne("competency_id=". $competency->getPrimaryKeyID);
	$competency_class_meet->delete();       
    } elsif ($competency_level eq "content") {
	my $competency_content = TUSK::Competency::Content->lookupReturnOne("competency_id=". $competency->getPrimaryKeyID);
	$competency_content->delete();
    } else {
	return 0;
    }
    $self->delete;
    return 1;
}


#######################################################

=item B<update>
    Change different values for the given competency
=cut

sub update {
    
    my ($self, $extra_cond) = @_;

    my $competency = $self->{competency};

    $competency->setFieldValues ({
	title => (defined $self->{title}) ? $self->{title}: $competency->getTitle,
	description => (defined $self->{description}) ? $self->{description}: $competency->getDescription,
	competency_user_type_id => (defined $self->{user_type_id}) ? $self->{user_type_id}: $competency->getCompetencyUserTypeID,
	school_id => (defined $self->{school_id}) ? $self->{school_id}: $competency->getSchoolID,
	competency_level_enum_id => (defined $self->{competency_level_enum_id}) ? $self->{competency_level_enum_id}: $competency->getCompetencyLevelEnumID,
	version_id => (defined $self->{version_id}) ? $self->{version_id}: $competency->getVersionID
    });

    $competency->save({user => $self->{user}});
}


#######################################################

=item B<add>
    Adds a new competency
=cut

sub add {

    my ($self, $extra_cond) = @_;

    my $competency = $self->{competency};

    $competency->setFieldValues({
	title => $self->{title},
	description => $self->{description},
	competency_user_type_id => $self->{user_type_id},
	school_id => $self->{school_id},
	competency_level_enum_id => $self->{competency_level_enum_id},
	version_id => $self->{version_id}
    });

    $competency->save({user => $self->{user}});

    return $competency->getPrimaryKeyID;
}
#######################################################

=item B<addChild>
    Adds a new competency as a child to the current competency
=cut

sub addChild {

    my ($self, $extra_cond) = @_;

    my $child_competency = TUSK::Competency::Competency->new();

    $child_competency->setFieldValues({    
	title => $self->{title},
	description => $self->{description},
	competency_user_type_id => $self->{user_type_id},
	school_id => $self->{school_id},
	competency_level_enum_id => $self->{competency_level_enum_id},
	version_id => $self->{version_id}
    });

    $child_competency->save({user => $self->{user}});

    my $child_competency_id = $child_competency->getPrimaryKeyID;

    my $hierarchy = TUSK::Competency::Hierarchy->new();

    $hierarchy->setFieldValues({
	school_id => $self->{school_id},
	lineage => $extra_cond->{lineage},
	sort_order => $extra_cond->{sort_order},
	depth => $extra_cond->{depth},
	parent_competency_id => $self->{competency_id},
	child_competency_id => $child_competency_id,
    });

    $hierarchy->save({user => $self->{user}});

    return $child_competency_id;
}


#######################################################

=item B<getLinked>
    returns the competencies that have been linked to the current competency.
=cut

sub getLinked {
    my ($self, $extra_cond) = @_;

    my $competency_id_2 = $self->{competency_id};
    
    my $linked_hierarchy = TUSK::Competency::Competency->lookup( 'competency_relation.competency_id_2 =' . $competency_id_2,
                [ 'competency_relation.competency_id_1', 'competency_relation.competency_id_2', 'competency.title', 'competency.description' ],
                undef, undef,
	        [ TUSK::Core::JoinObject->new('TUSK::Competency::Relation', { origkey=> 'competency_id', joinkey=> 'competency_id_1', jointype=> 'inner'})]);

    my @linked_competencies;

    foreach my $linked_competency (@{$linked_hierarchy}) {
	push @linked_competencies, $linked_competency->getJoinObject("TUSK::Competency::Relation")->getCompetencyId1;
    }

    return \@linked_competencies;
}

#######################################################



1;
