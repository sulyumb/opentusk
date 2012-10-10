package HSDB45::Eval::Secret;

use strict;
use HSDB4::Constants;
use HSDB4::DateTime;
use Digest::MD5;

# INPUT:  A string containing a school, a string containing an eval_id,
#         a string containing a user_id, an HSDB4::DateTime object and an md5 hashcode
# OUTPUT: A Boolean value
# EFFECT: Generates an md5 hashcode string for the first four arguments,
#         compares it to the hashcode passed in, and returns true if they match,
#         and false if they don't
sub verify_hashcode {
    my $school   = shift();
    my $eval_id  = shift();
    my $user_id  = shift();
    my $datetime = shift();
    my $hashcode = shift();

    my $generated_hashcode = generate_hashcode($school, $eval_id, $user_id, $datetime);
    return ($hashcode eq $generated_hashcode) ? 1 : 0;
}

# INPUT:  A string containing a school, a string containing an eval_id,
#         a string containing a user_id, and an HSDB4::DateTime object
# OUTPUT: An md5 hash string
# EFFECT: Takes the four arguments, looks up the secret associated with the specified
#         school and date, then generates an md5 hash string from all those things and returns it
sub generate_hashcode {
    my $school   = shift();
    my $eval_id  = shift();
    my $user_id  = shift();
    my $datetime = shift();

    my $ctx = Digest::MD5->new();
    $ctx->add(lc($school));
    $ctx->add($eval_id);
    $ctx->add(lc($user_id));
    my $timestamp = $datetime->out_mysql_timestamp();
    $timestamp =~ s/\D//g;
    $ctx->add($timestamp);
    $ctx->add(associated_secret($school, $datetime));

    return $ctx->b64digest();
}

# INPUT:  A string containing a school, and an HSDB4::DateTime object
# OUTPUT: A string containing a secret
# EFFECT: Takes the school and the DateTime object and
#         returns the associated secret string from the eval_secret table
sub associated_secret {
    my $school = shift();
    my $datetime = shift();

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($school);
    my $secret = "";

    eval {
	my $sth = $dbh->prepare("SELECT * FROM $db\.eval_secret ORDER BY secret_id");
	$sth->execute();
	while(my $hash_ref = $sth->fetchrow_hashref()) {
	    my $secret_datetime = HSDB4::DateTime->new()->in_mysql_timestamp($hash_ref->{'created'});

	    if($secret_datetime->compare($datetime) <= 0) {
		$secret = $hash_ref->{'secret'};
	    }
	    else {
		last;
	    }
	}
    };

    return $secret;
}

1;
