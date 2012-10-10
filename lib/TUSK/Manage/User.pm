package TUSK::Manage::User;

use strict;

use HSDB4::Constants;
use HSDB4::SQLRow::User;
use HSDB45::UserGroup;
use HSDB45::LDAP;
use TUSK::Constants;
use Data::Dumper;
use Scalar::Util 'reftype';

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub add_process{
    my ($req, $fdat) = @_;

	# don't allow any spaces in userid
	# Apache::TicketMaster removes spaces from userid's when 
	# logging in anyway, so do same thing when establishing id.
	$fdat->{userid} =~ s/\s//g;

    my $user = HSDB4::SQLRow::User->new->lookup_key($fdat->{userid});
    if ($user->primary_key){
	return (0, "User ID already exists.<br>Please choose another User ID.");
    }
    return (1);
}

sub addedit_process{
    my ($req,$id,$school, $fdat) = @_;
    my ($rval, $msg);
	

	my $useredit;

    if ($fdat->{action} eq "add"){

		$useredit = HSDB4::SQLRow::User->new;
		$useredit->primary_key($id);
	
		$fdat->{page} = "edit";
		$fdat->{msg} = "User added successfully.";
	
		my $groupref = $fdat->{groups};
		my $reftype = reftype $groupref;

		if($reftype eq 'ARRAY'){
			foreach my $group ($groupref){
				foreach my $g (@$group){
					($rval, $msg) = HSDB45::UserGroup->new(_school=>$school)->lookup_key($g)->add_child_user($un, $pw, $fdat->{userid});
					return ($rval, $msg) if ($rval < 1);
				}
			}
		} else {
			if($groupref){
				($rval, $msg) = HSDB45::UserGroup->new(_school=>$school)->lookup_key($groupref)->add_child_user($un, $pw, $fdat->{userid});
				return ($rval, $msg) if ($rval < 1);
			}
	}

    } else {
		$useredit = HSDB4::SQLRow::User->new->lookup_key( $id );
	}

    my $additional_msg;
    my $isldap;
  
   if ($fdat->{source} eq "external") {
		my $ldap = HSDB45::LDAP->new;
		my ($res,$m) = $ldap->lookup_user_id($fdat->{userid});
		if ($res) {
            $useredit->set_first_name($ldap->firstname);
            $useredit->set_last_name($ldap->lastname);
            $useredit->set_email($ldap->email);
			$useredit->set_field_values(password => '',
					       source => 'external',
					       );

		$isldap=1;
	} else {
	    $additional_msg = " User not found in ".$TUSK::Constants::SchoolShort." Authentication, source set to ".$TUSK::Constants::SiteAbbr.".";

		$isldap=0;
	    $fdat->{source} = 'internal';
	}
    } else {

		$isldap=0;
    }

    unless ($isldap){
        $useredit->set_first_name($fdat->{firstname});
        $useredit->set_last_name($fdat->{lastname});
        $useredit->set_email($fdat->{email});
	    $useredit->set_field_values(source => 'internal');	
    }

    $useredit->set_field_values(affiliation  => $fdat->{affiliation},
				       degree => ($fdat->{degree} eq 'Other') ? $fdat->{degree_text} : $fdat->{degree},
				       midname => $fdat->{midname},
				       suffix => $fdat->{suffix},
				       gender => $fdat->{gender},
				       expires => $fdat->{expires},
				       status => $fdat->{status},
				       tufts_id => $fdat->{tufts_id},
				       sid => $fdat->{sid},
				       );
    
    ($rval, $msg) = $useredit->save($un, $pw);    
    if ($rval){
	if ($fdat->{reset_password} && $fdat->{source} eq "internal") {
	    $useredit->admin_reset_password();
	    $additional_msg = " Password sent to user.".$additional_msg;
	}
	if ($fdat->{action} eq "add"){
	    my $user_id = $useredit->primary_key();
		$user_id =~ s#/#%2F#g;
	    return (1, "User added successfully.$additional_msg");
	}else{
	    return (1, "User updated successfully.$additional_msg");
	}
    }else{
	return ($rval, $msg);
    }
}

sub addedit_pre_process{
    my ($req,$id,$school,$fdat) = @_;
    my $data;
    
	my $useredit = HSDB4::SQLRow::User->new->lookup_key( $id );
#    $useredit = HSDB4::SQLRow::User->new->lookup_key( $id );
    $data->{tr_flag} = 0;
    
    $data->{course_schools} = [ &HSDB4::Constants::course_schools ];

    if ($fdat->{page} eq "add"){
		$useredit = HSDB4::SQLRow::User->new();
###		$data->{$useredit} = HSDB4::SQLRow::User->new();

		my $ldap = HSDB45::LDAP->new;
		my ($res,$m) = $ldap->lookup_user_id($fdat->{userid});
	
		if ($res) {
            $useredit->set_first_name($ldap->firstname);
            $useredit->set_last_name($ldap->lastname);
			$useredit->set_email($ldap->email);

			$useredit->field_value("source", "external");
			
		}
		
	$data->{useredit} = $useredit;

	my $user_id = $fdat->{userid};
	$user_id =~ s#/#%2F#g;
	$data->{userid} = $fdat->{userid};
	
	$data->{usergroups} = [ HSDB45::UserGroup->new( _school => $school )->lookup_conditions("sub_group='No'", "order by label") ];
		
	$data->{usergrouplabel} = "Assign to Groups:";

    } else {
#		$data->{userid} = $useredit->primary_key;
		$data->{userid} = $id;
		$data->{usergroups} = [ $useredit->parent_user_groups ];
		$data->{usergrouplabel} = "Groups:";
    }

    return $data;
}


sub show_pre_process{
	my ($req, $fdat) = @_;
	my $data;
	$data->{isAdvanced} = 0;
	if ($fdat->{Submit}){
		my $lookupConditions = "";
		if($fdat->{advanced}) {
			$data->{isAdvanced} = 1;
			my $last = $fdat->{lastName};
			$last =~ s/'/\\'/g;
			my $middle = $fdat->{middleName};
			$middle =~ s/'/\\'/g;
			my $first = $fdat->{firstName};
			$first =~ s/'/\\'/g;
			if($first || $middle || $last) {
				if($last) {$lookupConditions .= "lastname like '\%" . $last . "\%'";}
				if($middle) {
					if($lookupConditions) {$lookupConditions .= " AND ";}
					$lookupConditions.= "midname like '\%" . $middle . "\%'";
				}
				if($first) {
					if($lookupConditions) {$lookupConditions .= " AND ";}
					$lookupConditions.= "firstname like '\%" . $first . "\%'";
				}
			}
		} else {
			my $search = $fdat->{simpleSearch};
			$search =~ s/'/\\'/g;
			if($search) {
				$lookupConditions = "firstname like '\%$search\%' OR midname like '\%$search\%' OR lastname like '\%$search\%'";
			}
		}
		if($lookupConditions) {
			$data->{results} = [ HSDB4::SQLRow::User->new->lookup_conditions($lookupConditions,"order by lastname, firstname") ];
		}
		$data->{lookupConditions} = $lookupConditions;
	}
	return $data;
}
